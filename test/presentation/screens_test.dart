import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/settings/appearance_controller.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/browser/browser_screen.dart';
import 'package:prism_browser/presentation/onboarding/onboarding_screen.dart';

import '../helpers/pump_app.dart';

const _routes = [
  '/',
  '/?panel=omnibox',
  '/?panel=find',
  '/tabs',
  '/tabs?incognito=1',
  '/bookmarks',
  '/history',
  '/downloads',
  '/settings',
  '/settings/appearance',
  '/settings/privacy',
  '/settings/search',
  '/settings/permissions',
];

void main() {
  testWidgets('fresh install lands on onboarding; finishing opens browser', (
    tester,
  ) async {
    final c = await pumpRoutedApp(tester, settings: const AppearanceSettings());
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Pick Material on the style step: applies immediately.
    await tester.tap(find.text('Material 3').first);
    await tester.pumpAndSettle();
    expect(c.read(appearanceProvider).style, PrismStyleId.material);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(c.read(appearanceProvider).onboardingDone, isTrue);
    expect(find.byType(BrowserScreen), findsOneWidget);
  });

  for (final style in PrismStyleId.values) {
    for (final route in _routes) {
      testWidgets('$route renders in ${style.name} (phone, a11y)', (
        tester,
      ) async {
        await pumpRoutedApp(
          tester,
          location: route,
          settings: AppearanceSettings(style: style, onboardingDone: true),
        );
        expect(tester.takeException(), isNull);
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  }

  testWidgets('wide window shows desktop chrome with tab strip', (
    tester,
  ) async {
    await pumpRoutedApp(tester, size: const Size(1280, 800));
    // Pinned tabs are icon-only in the strip; check a regular one.
    expect(find.text('DuckDuckGo — приватный поиск'), findsOneWidget);
    expect(find.byTooltip('Свернуть'), findsOneWidget);
  });

  testWidgets('menu sheet opens via deep link and navigates', (tester) async {
    await pumpRoutedApp(tester, location: '/?panel=menu');
    expect(find.text('Найти на странице'), findsOneWidget);
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('Поиск в истории'), findsOneWidget);
  });

  testWidgets('address bar at the bottom on request', (tester) async {
    await pumpRoutedApp(
      tester,
      settings: const AppearanceSettings(
        onboardingDone: true,
        addressBarPosition: AddressBarPosition.bottom,
      ),
    );
    final bar = tester.getCenter(find.text('ru.wikipedia.org'));
    expect(bar.dy, greaterThan(915 / 2));
  });
}
