import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/data/engine/inappwebview_engine.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';
import 'package:prism_browser/presentation/browser/start_page.dart';

import '../helpers/pump_app.dart';

Future<(ProviderContainer, FakeEngine)> _pump(
  WidgetTester tester, {
  bool demo = false,
  String location = '/',
  FakeEngine? engine,
}) async {
  setSurface(tester, const Size(412, 915), const Locale('ru'));
  final e = engine ?? FakeEngine();
  final c = await makeContainer(
    settings: const AppearanceSettings(onboardingDone: true),
    location: location,
    engine: e,
    demo: demo,
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const PrismApp()),
  );
  await tester.pumpAndSettle();
  return (c, e);
}

void main() {
  testWidgets('clean start: start page, no navigation, empty library', (
    tester,
  ) async {
    final (c, engine) = await _pump(tester);
    expect(find.byType(StartPage), findsOneWidget);
    expect(engine.loadLog, isEmpty, reason: 'no network on a clean start');
    expect(c.read(tabsProvider).tabs, hasLength(1));

    await tester.tap(find.byTooltip('Меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('История пуста'), findsOneWidget);
  });

  testWidgets('omnibox opens an address; back returns', (tester) async {
    final (c, engine) = await _pump(tester);

    await tester.tap(find.text('Поиск или адрес').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'example.com');
    await tester.pumpAndSettle();
    expect(find.text('Перейти по адресу'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(engine.loadLog, ['https://example.com']);
    expect(find.byType(StartPage), findsNothing);
    expect(find.text('example.com'), findsWidgets);

    await c.read(browserActionsProvider).open('призма оптика');
    await tester.pumpAndSettle();
    expect(engine.loadLog.last, startsWith('https://duckduckgo.com/?q='));
    expect(c.read(pageStateProvider).canGoBack, isTrue);

    await c.read(browserActionsProvider).back();
    await tester.pumpAndSettle();
    expect(c.read(pageStateProvider).url.toString(), 'https://example.com');
    expect(c.read(pageStateProvider).canGoForward, isTrue);
  });

  testWidgets('closing a tab disposes its session cleanly', (tester) async {
    final (c, _) = await _pump(tester, demo: true);
    final before = c.read(tabsProvider).tabs.length;
    c.read(tabsProvider.notifier).close('t1');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(c.read(tabsProvider).tabs.length, before - 1);
  });

  testWidgets('glass degrades to opaque over unblurrable content', (
    tester,
  ) async {
    await _pump(tester, demo: true);
    final withBlur = find.byType(BackdropFilter).evaluate().length;
    expect(withBlur, greaterThan(0));

    await _pump(tester, demo: true, engine: FakeEngine(blursContent: false));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  test('Android WebView privacy defaults', () {
    final s = AndroidEngine().settings(incognito: false);
    expect(s.safeBrowsingEnabled, isFalse, reason: 'no Google lookups');
    expect(s.thirdPartyCookiesEnabled, isFalse);
    expect(s.mixedContentMode, MixedContentMode.MIXED_CONTENT_NEVER_ALLOW);
    expect(s.allowFileAccess, isFalse);
    expect(s.useHybridComposition, isFalse, reason: 'TLHC: glass can blur');
    expect(AndroidEngine().capabilities.incognitoWithoutDisk, isFalse);
    expect(
      AndroidEngine(hybridComposition: true)
          .capabilities
          .contentUnderChromeBlurs,
      isFalse,
    );
  });
}
