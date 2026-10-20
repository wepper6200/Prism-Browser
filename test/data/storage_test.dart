import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/data/storage/database.dart';
import 'package:prism_browser/data/storage/drift_repositories.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/browser/repositories.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late PrismDatabase db;

  setUp(() => db = PrismDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('tabs', () {
    test('first launch has no session', () async {
      expect(await DriftTabsRepository(db).load(), isNull);
    });

    test('saves order, pins, groups and active tab; skips incognito', () async {
      final repo = DriftTabsRepository(db);
      await repo.save(
        const TabsSnapshot(
          tabs: [
            BrowserTab(
              id: 'a',
              title: 'A',
              url: 'https://a.example',
              pinned: true,
            ),
            BrowserTab(
              id: 'secret',
              title: 'S',
              url: 'https://s.example',
              incognito: true,
            ),
            BrowserTab(
              id: 'b',
              title: 'B',
              url: 'https://b.example',
              groupId: 'g',
            ),
            BrowserTab(id: 'c', title: '', url: ''),
          ],
          groups: [TabGroup(id: 'g', name: 'Работа', color: 0xFF38BDF8)],
          activeId: 'b',
        ),
      );
      final s = (await repo.load())!;
      expect(s.tabs.map((t) => t.id), ['a', 'b', 'c']);
      expect(s.tabs.first.pinned, isTrue);
      expect(s.tabs[1].groupId, 'g');
      expect(s.tabs.every((t) => !t.loaded), isTrue, reason: 'restored cold');
      expect(s.groups.single.name, 'Работа');
      expect(s.activeId, 'b');
    });

    test('save replaces the previous session', () async {
      final repo = DriftTabsRepository(db);
      await repo.save(
        const TabsSnapshot(
          tabs: [BrowserTab(id: 'a', title: 'A', url: 'https://a')],
          groups: [],
          activeId: 'a',
        ),
      );
      await repo.save(
        const TabsSnapshot(
          tabs: [BrowserTab(id: 'z', title: 'Z', url: 'https://z')],
          groups: [],
          activeId: 'z',
        ),
      );
      final s = (await repo.load())!;
      expect(s.tabs.single.id, 'z');
      expect(s.activeId, 'z');
    });
  });

  group('history', () {
    test('records, searches (escaped LIKE), renames, deletes', () async {
      final repo = DriftHistoryRepository(db);
      final t0 = DateTime(2026, 10, 20, 12);
      final id = await repo.addVisit('https://flutter.dev', '', t0);
      await repo.updateTitle(id, 'Flutter');
      await repo.addVisit(
        'https://example.com/100%_real',
        '100% real',
        t0.add(const Duration(minutes: 1)),
      );
      await repo.addVisit(
        'https://dart.dev',
        'Dart',
        t0.add(const Duration(minutes: 2)),
      );

      var all = await repo.watch().first;
      expect(all.map((h) => h.title), ['Dart', '100% real', 'Flutter']);

      expect(
        (await repo.watch(query: 'FLUTTER').first).single.url,
        'https://flutter.dev',
      );
      expect((await repo.watch(query: '100%').first).single.title, '100% real');
      expect(
        await repo.watch(query: '%').first,
        hasLength(1),
        reason: '% is literal',
      );
      expect(
        await repo.watch(query: '_').first,
        hasLength(1),
        reason: '_ is literal',
      );

      await repo.delete(all.first.id);
      all = await repo.watch().first;
      expect(all.map((h) => h.title), ['100% real', 'Flutter']);
    });

    test('clear by period keeps older visits', () async {
      final repo = DriftHistoryRepository(db);
      final now = DateTime(2026, 10, 20, 12);
      await repo.addVisit(
        'https://old.example',
        'old',
        now.subtract(const Duration(days: 3)),
      );
      await repo.addVisit(
        'https://new.example',
        'new',
        now.subtract(const Duration(minutes: 30)),
      );
      await repo.clear(since: now.subtract(const Duration(hours: 1)));
      expect((await repo.watch().first).single.title, 'old');
      await repo.clear();
      expect(await repo.watch().first, isEmpty);
    });

    test('suggestions: one row per URL, most visited first', () async {
      final repo = DriftHistoryRepository(db);
      final t = DateTime(2026, 10, 20);
      for (var i = 0; i < 3; i++) {
        await repo.addVisit(
          'https://prism.example',
          'Prism',
          t.add(Duration(minutes: i)),
        );
      }
      await repo.addVisit(
        'https://prismatic.example',
        'Prismatic',
        t.add(const Duration(hours: 1)),
      );
      final s = await repo.suggest('prism');
      expect(s.map((h) => h.url), [
        'https://prism.example',
        'https://prismatic.example',
      ]);
      expect(await repo.suggest('  '), isEmpty);
    });
  });

  group('bookmarks', () {
    test(
      'folders, edit, delete by URL; deleting a folder keeps bookmarks',
      () async {
        final repo = DriftBookmarksRepository(db);
        final emissions = <BookmarksData>[];
        final sub = repo.watch().listen(emissions.add);

        await repo.addFolder(const BookmarkFolder(id: 'f', name: 'Dev'));
        await repo.addBookmark(
          const Bookmark(
            id: 'b1',
            title: 'Flutter',
            url: 'https://flutter.dev',
            folderId: 'f',
          ),
        );
        await repo.addBookmark(
          const Bookmark(id: 'b2', title: 'Dart', url: 'https://dart.dev'),
        );
        await repo.updateBookmark(
          const Bookmark(
            id: 'b2',
            title: 'Dart lang',
            url: 'https://dart.dev',
            folderId: 'f',
          ),
        );
        await repo.renameFolder('f', 'Разработка');
        await pumpEventQueue();

        var data = emissions.last;
        expect(data.folders.single.name, 'Разработка');
        expect(data.bookmarks.where((b) => b.folderId == 'f'), hasLength(2));

        await repo.deleteFolder('f');
        await repo.deleteByUrl('https://flutter.dev');
        await pumpEventQueue();
        data = emissions.last;
        expect(data.folders, isEmpty);
        expect(data.bookmarks.single.title, 'Dart lang');
        expect(data.bookmarks.single.folderId, isNull);
        await sub.cancel();
      },
    );
  });

  group('downloads', () {
    test('upsert updates progress; incognito downloads never stored', () async {
      final repo = DriftDownloadsRepository(db);
      const d = DownloadItem(
        id: 'd1',
        fileName: 'a.pdf',
        url: 'https://a.example/a.pdf',
        totalBytes: 100,
        receivedBytes: 10,
        state: DownloadState.running,
        filePath: '/tmp/a.pdf',
      );
      await repo.upsert(d);
      await repo.upsert(
        d.copyWith(receivedBytes: 100, state: DownloadState.completed),
      );
      await repo.upsert(
        const DownloadItem(
          id: 'secret',
          fileName: 's.zip',
          url: 'https://s.example/s.zip',
          totalBytes: 1,
          receivedBytes: 0,
          state: DownloadState.running,
          incognito: true,
        ),
      );
      final all = await repo.all();
      expect(all.single.state, DownloadState.completed);
      expect(all.single.receivedBytes, 100);
      await repo.delete('d1');
      expect(await repo.all(), isEmpty);
    });
  });
}
