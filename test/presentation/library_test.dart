import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/domain/browser/download_names.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';
import 'package:prism_browser/presentation/app/router.dart';
import 'package:prism_browser/presentation/browser/chrome_widgets.dart';

import '../helpers/pump_app.dart';

Future<(ProviderContainer, FakeEngine)> _pump(
  WidgetTester tester, {
  bool demo = false,
  FakeTransport? transport,
  FakePlatformFiles? files,
}) async {
  setSurface(tester, const Size(412, 915), const Locale('ru'));
  final engine = FakeEngine();
  final c = await makeContainer(
    settings: const AppearanceSettings(onboardingDone: true),
    engine: engine,
    demo: demo,
    transport: transport,
    files: files,
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const PrismApp()),
  );
  await tester.pumpAndSettle();
  return (c, engine);
}

/// Drift streams and file I/O complete outside the fake clock.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menu bookmarks the page; it appears in Bookmarks', (
    tester,
  ) async {
    final (c, _) = await _pump(tester);
    await c.read(browserActionsProvider).open('example.com');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('В закладки'));
    await _settle(tester);
    expect(find.text('Добавлено в закладки'), findsOneWidget);
    expect(c.read(isBookmarkedProvider('https://example.com')), isTrue);

    c.read(routerProvider).go('/bookmarks');
    await _settle(tester);
    expect(find.text('example.com'), findsWidgets);
  });

  testWidgets('history: clear everything empties the list', (tester) async {
    final (c, _) = await _pump(tester, demo: true);
    c.read(routerProvider).go('/history');
    await _settle(tester);
    expect(find.text('Хабр — Как работает WebView2'), findsOneWidget);

    await tester.tap(find.byTooltip('Очистить историю'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('За всё время'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить').last);
    await _settle(tester);
    expect(find.text('История пуста'), findsOneWidget);
  });

  testWidgets('a page download shows a toast and finishes in Downloads', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('prism_ui_dl');
    addTearDown(() => dir.deleteSync(recursive: true));
    final transport = FakeTransport(
      files: {'https://a.example/manual.pdf': List.filled(32, 7)},
    );
    final (c, engine) = await _pump(
      tester,
      transport: transport,
      files: FakePlatformFiles(dir.path),
    );
    engine.simulateDownload(
      DownloadRequest(
        url: Uri.parse('https://a.example/manual.pdf'),
        incognito: false,
      ),
    );
    await _settle(tester);
    await _settle(tester);
    expect(find.text('Загружается: manual.pdf'), findsOneWidget);

    // File I/O runs on real time, the transfer on the test clock: alternate.
    for (var i = 0; i < 40; i++) {
      if (c.read(downloadsProvider).single.state == DownloadState.completed) {
        break;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    c.read(routerProvider).go('/downloads');
    await _settle(tester);
    expect(find.text('manual.pdf'), findsOneWidget);
    expect(find.byTooltip('Открыть файл'), findsOneWidget);
  });

  testWidgets('tab switcher: put a tab into a new group', (tester) async {
    final (c, _) = await _pump(tester);
    await c.read(browserActionsProvider).open('example.com');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/tabs');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Новая группа'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Учёба');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(c.read(tabsProvider).groups.single.name, 'Учёба');
    expect(find.text('Учёба'), findsOneWidget);
  });

  testWidgets('incognito pages carry a visible mark', (tester) async {
    final (c, _) = await _pump(tester);
    c.read(tabsProvider.notifier).newTab(incognito: true);
    await c.read(browserActionsProvider).open('example.com');
    await tester.pumpAndSettle();
    expect(find.byType(IncognitoMark), findsOneWidget);
    expect(find.byTooltip('Режим инкогнито'), findsOneWidget);
  });
}
