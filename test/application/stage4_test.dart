import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/data/storage/database.dart';
import 'package:prism_browser/data/storage/drift_repositories.dart';
import 'package:prism_browser/domain/browser/download_names.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/browser/repositories.dart';

import '../helpers/pump_app.dart';

/// Lets drift streams and fire-and-forget writes settle.
Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await pumpEventQueue();
  }
}

void main() {
  group('tabs: session restore', () {
    test('every change is saved; a new run restores tabs cold', () async {
      final db = PrismDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final c = await makeContainer(demo: false, db: db);
      final tabs = c.read(tabsProvider.notifier);
      final a = tabs.newTab(url: 'https://a.example');
      tabs.updateMeta(a, title: 'A');
      tabs.togglePin(a);
      final g = tabs.createGroup('Работа', 0xFF38BDF8, withTab: a);
      final b = tabs.newTab(url: 'https://b.example');
      tabs.newTab(incognito: true, url: 'https://secret.example');
      tabs.select(b);
      await tabs.flush();
      c.dispose();

      final saved = await DriftTabsRepository(db).load();
      expect(saved!.activeId, b);
      expect(saved.tabs.map((t) => t.url), [
        '',
        'https://a.example',
        'https://b.example',
      ]);
      expect(saved.tabs.any((t) => t.url.contains('secret')), isFalse);

      final c2 = await makeContainer(demo: false, db: db, session: saved);
      addTearDown(c2.dispose);
      final s = c2.read(tabsProvider);
      expect(s.activeId, b);
      final restoredA = s.tabs.firstWhere((t) => t.id == a);
      expect(restoredA.title, 'A');
      expect(restoredA.pinned, isTrue);
      expect(restoredA.groupId, g);
      expect(restoredA.loaded, isFalse, reason: 'inactive tabs restore cold');
      expect(s.active.loaded, isTrue);
      expect(s.groups.single.name, 'Работа');
      expect(s.incognitoTabs, isEmpty, reason: 'incognito never restored');
    });

    test('groups: rename, ungroup, delete keeps tabs', () async {
      final c = await makeContainer(demo: false);
      addTearDown(c.dispose);
      final tabs = c.read(tabsProvider.notifier);
      final t = tabs.newTab(url: 'https://a.example');
      final g = tabs.createGroup('A', 1, withTab: t);
      tabs.renameGroup(g, ' B ');
      expect(c.read(tabsProvider).groups.single.name, 'B');
      tabs.deleteGroup(g);
      expect(c.read(tabsProvider).groups, isEmpty);
      final tab = c.read(tabsProvider).tabs.firstWhere((x) => x.id == t);
      expect(tab.groupId, isNull);
    });

    test('lazy tabs: at most maxLiveTabs alive, memory pressure unloads all '
        'but the visible one', () async {
      final c = await makeContainer(demo: false);
      addTearDown(c.dispose);
      final tabs = c.read(tabsProvider.notifier);
      for (var i = 0; i < TabsController.maxLiveTabs + 3; i++) {
        final id = tabs.newTab(url: 'https://$i.example');
        tabs.select(id);
      }
      int live() => c.read(tabsProvider).all.where((t) => t.loaded).length;
      expect(live(), lessThanOrEqualTo(TabsController.maxLiveTabs));
      tabs.unloadInactive();
      expect(live(), 1);
      expect(c.read(tabsProvider).active.loaded, isTrue);
    });
  });

  group('history', () {
    test(
      'finished loads of regular tabs are recorded; incognito never',
      () async {
        final engine = FakeEngine();
        final c = await makeContainer(demo: false, engine: engine);
        addTearDown(c.dispose);
        final sub = c.listen(pageStateProvider, (_, _) {});
        addTearDown(sub.close);
        await c.read(browserActionsProvider).open('example.com');
        await settle();
        final tabs = c.read(tabsProvider.notifier);
        tabs.newTab(incognito: true);
        await c.read(browserActionsProvider).open('secret.example');
        await settle();

        final h = await c.read(historyRepositoryProvider).watch().first;
        expect(h.map((e) => e.url), ['https://example.com']);
      },
    );

    test('clear by range uses the clock', () async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      final repo = c.read(historyRepositoryProvider);
      expect(await repo.watch().first, hasLength(7));
      await c.read(historyActionsProvider).clear(ClearRange.hour);
      final left = await repo.watch().first;
      expect(
        left.every((e) => fixedNow.difference(e.visitedAt).inHours >= 1),
        isTrue,
      );
      await c.read(historyActionsProvider).clear(ClearRange.all);
      expect(await repo.watch().first, isEmpty);
    });
  });

  group('bookmarks', () {
    test('star toggles; folders delete without losing bookmarks', () async {
      final c = await makeContainer(demo: false);
      addTearDown(c.dispose);
      final sub = c.listen(bookmarksProvider, (_, _) {});
      addTearDown(sub.close);
      final marks = c.read(bookmarkActionsProvider);
      expect(await marks.toggle('https://a.example', 'A'), isTrue);
      await settle();
      expect(c.read(isBookmarkedProvider('https://a.example')), isTrue);
      expect(await marks.toggle('https://a.example', 'A'), isFalse);
      await settle();
      expect(c.read(bookmarksProvider), isEmpty);

      final f = await marks.addFolder('Почитать');
      await marks.toggle('https://b.example', 'B');
      await settle();
      final b = c.read(bookmarksProvider).single;
      await marks.update(
        Bookmark(id: b.id, title: 'Bee', url: b.url, folderId: f),
      );
      await marks.deleteFolder(f);
      await settle();
      expect(c.read(bookmarkFoldersProvider), isEmpty);
      expect(c.read(bookmarksProvider).single.title, 'Bee');
      expect(c.read(bookmarksProvider).single.folderId, isNull);
    });
  });

  group('omnibox', () {
    test('local suggestions from bookmarks and history, no network', () async {
      final suggest = FakeSuggestClient();
      final c = await makeContainer(suggest: suggest);
      addTearDown(c.dispose);
      final sub = c.listen(bookmarksProvider, (_, _) {});
      addTearDown(sub.close);
      await settle();
      expect(await c.read(localSuggestionsProvider('').future), isEmpty);
      final s = await c.read(localSuggestionsProvider('призм').future);
      expect(s.any((x) => x.kind == SuggestionKind.bookmark), isTrue);
      expect(s.any((x) => x.kind == SuggestionKind.history), isTrue);
      expect(suggest.calls, isEmpty);
    });

    test('engine suggestions: only when enabled and not incognito', () async {
      final suggest = FakeSuggestClient();
      final c = await makeContainer(demo: false, suggest: suggest);
      addTearDown(c.dispose);
      var s = await c.read(remoteSuggestionsProvider('prism').future);
      expect(s.first.title, 'prism browser');
      expect(suggest.calls.single.$1, SearchEngineId.duckduckgo);

      c.read(searchSuggestionsEnabledProvider.notifier).set(false);
      s = await c.read(remoteSuggestionsProvider('prism x').future);
      expect(s, isEmpty);

      c.read(searchSuggestionsEnabledProvider.notifier).set(true);
      c.read(tabsProvider.notifier).newTab(incognito: true);
      s = await c.read(remoteSuggestionsProvider('prism y').future);
      expect(s, isEmpty);
      expect(suggest.calls, hasLength(1));
    });
  });

  group('downloads', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('prism_dl'));
    tearDown(() => dir.deleteSync(recursive: true));

    Future<(ProviderContainer, FakeEngine, FakeTransport, FakePlatformFiles)>
    setup({bool ranges = true}) async {
      final engine = FakeEngine();
      final transport = FakeTransport(
        ranges: ranges,
        files: {'https://a.example/report.pdf': List.generate(64, (i) => i)},
      );
      final files = FakePlatformFiles(dir.path);
      final c = await makeContainer(
        demo: false,
        engine: engine,
        transport: transport,
        files: files,
      );
      addTearDown(c.dispose);
      c.listen(downloadsProvider, (_, _) {});
      return (c, engine, transport, files);
    }

    final req = DownloadRequest(
      url: Uri.https('a.example', '/report.pdf'),
      incognito: false,
      mimeType: 'application/pdf',
    );

    test('a page download is saved, listed and persisted', () async {
      final (c, engine, _, files) = await setup();
      engine.simulateDownload(req);
      await settle();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await settle();
      final d = c.read(downloadsProvider).single;
      expect(d.state, DownloadState.completed);
      expect(d.fileName, 'report.pdf');
      expect(File(d.filePath).readAsBytesSync(), List.generate(64, (i) => i));
      expect(File('${d.filePath}.part').existsSync(), isFalse);
      final saved = await c.read(downloadsRepositoryProvider).all();
      expect(saved.single.state, DownloadState.completed);
      expect(await c.read(downloadsProvider.notifier).open(d.id), isTrue);
      expect(files.opened.single, d.filePath);
    });

    test('pause keeps the part file; resume continues with Range', () async {
      final (c, _, transport, _) = await setup();
      transport.stallAfter = 16;
      final dl = c.read(downloadsProvider.notifier);
      final started = dl.start(req);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final id = c.read(downloadsProvider).single.id;
      dl.pause(id);
      await started;
      var d = c.read(downloadsProvider).single;
      expect(d.state, DownloadState.paused);
      final part = File('${d.filePath}.part');
      expect(part.lengthSync(), 16);

      await dl.resume(id);
      d = c.read(downloadsProvider).single;
      expect(d.state, DownloadState.completed);
      expect(transport.requests.last.$2, 16, reason: 'asked for the rest');
      expect(File(d.filePath).readAsBytesSync(), List.generate(64, (i) => i));
    });

    test('server without Range support: resume starts over', () async {
      final (c, _, transport, _) = await setup(ranges: false);
      transport.stallAfter = 16;
      final dl = c.read(downloadsProvider.notifier);
      final started = dl.start(req);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      dl.pause(c.read(downloadsProvider).single.id);
      await started;
      await dl.resume(c.read(downloadsProvider).single.id);
      final d = c.read(downloadsProvider).single;
      expect(d.state, DownloadState.completed);
      expect(File(d.filePath).readAsBytesSync(), List.generate(64, (i) => i));
    });

    test(
      'HTTP errors fail; names never collide; remove deletes the part',
      () async {
        final (c, _, _, _) = await setup();
        final dl = c.read(downloadsProvider.notifier);
        final missing = await dl.start(
          DownloadRequest(
            url: Uri.parse('https://a.example/missing.zip'),
            incognito: false,
          ),
        );
        expect(missing.state, DownloadState.failed);
        final first = await dl.start(req);
        final second = await dl.start(req);
        expect(first.fileName, 'report.pdf');
        expect(second.fileName, 'report (1).pdf');
        await dl.remove(missing.id);
        expect(
          c.read(downloadsProvider).any((d) => d.id == missing.id),
          isFalse,
        );
      },
    );

    test(
      'data: URLs are saved directly; incognito downloads not stored',
      () async {
        final (c, _, _, _) = await setup();
        final dl = c.read(downloadsProvider.notifier);
        final d = await dl.start(
          DownloadRequest(
            url: Uri.parse('data:text/plain;base64,UHJpc20='),
            incognito: true,
            mimeType: 'text/plain',
          ),
        );
        expect(d.state, DownloadState.completed);
        expect(File(d.filePath).readAsStringSync(), 'Prism');
        expect(await c.read(downloadsRepositoryProvider).all(), isEmpty);
        dl.forgetIncognito();
        expect(c.read(downloadsProvider), isEmpty);
      },
    );

    test('unfinished downloads come back paused after a restart', () async {
      final db = PrismDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftDownloadsRepository(db).upsert(
        const DownloadItem(
          id: 'x',
          fileName: 'x.zip',
          url: 'https://a.example/x.zip',
          totalBytes: 10,
          receivedBytes: 3,
          state: DownloadState.running,
        ),
      );
      final c = await makeContainer(demo: false, db: db);
      addTearDown(c.dispose);
      c.listen(downloadsProvider, (_, _) {});
      await settle();
      expect(c.read(downloadsProvider).single.state, DownloadState.paused);
    });
  });

  test('incognito: nothing reaches the database', () async {
    final db = PrismDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final c = await makeContainer(demo: false, db: db);
    addTearDown(c.dispose);
    c.listen(pageStateProvider, (_, _) {});
    final tabs = c.read(tabsProvider.notifier);
    tabs.newTab(incognito: true);
    await c.read(browserActionsProvider).open('private.example');
    await settle();
    await tabs.flush();
    final saved = await DriftTabsRepository(db).load();
    expect(
      saved!.tabs.any((t) => t.incognito || t.url.contains('private')),
      isFalse,
    );
    expect(await DriftHistoryRepository(db).watch().first, isEmpty);
    expect(
      saved.activeId,
      isNull,
      reason: 'an incognito tab is never the restored one',
    );
    expect(
      const TabsSnapshot(tabs: [], groups: [], activeId: null).tabs,
      isEmpty,
    );
  });
}
