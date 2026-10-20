@Tags(['showcase'])
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/core/design/prism_icons.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';

import '../helpers/pump_app.dart';

/// Marketing-style boards rendered from the real app: every screen in
/// Liquid Glass / Material 3 x dark / light. Not a regression test:
///   flutter test --tags showcase --update-goldens test/showcase
/// then copy test/showcase/boards/*.png to docs/showcase/.

const _phone = Size(390, 844);
const _desktop = Size(1280, 800);
const _bg = Color(0xFF0A0D16);

class _Variant {
  const _Variant(this.style, this.mode, this.label);

  final PrismStyleId style;
  final PrismThemeMode mode;
  final String label;

  bool get dark => mode == PrismThemeMode.dark;
}

const _variants = [
  _Variant(PrismStyleId.glass, PrismThemeMode.dark, 'Liquid Glass · тёмная'),
  _Variant(PrismStyleId.glass, PrismThemeMode.light, 'Liquid Glass · светлая'),
  _Variant(PrismStyleId.material, PrismThemeMode.dark, 'Material 3 · тёмная'),
  _Variant(PrismStyleId.material, PrismThemeMode.light, 'Material 3 · светлая'),
];

class _Screen {
  const _Screen(
    this.file,
    this.title,
    this.location, {
    this.onboarding = false,
    this.tab,
    this.progress = 1,
    this.search,
  });

  final String file;
  final String title;
  final String location;
  final bool onboarding;
  final String? tab;
  final double progress;

  /// Opens Prism Search with this query in the active tab.
  final String? search;
}

const _screens = [
  _Screen(
    '01_onboarding',
    'Первый запуск: выбор стиля',
    '/onboarding',
    onboarding: true,
  ),
  _Screen('02_browser', 'Страница сайта', '/', progress: 0.62),
  _Screen('03_start_page', 'Новая вкладка', '/', tab: 't6'),
  _Screen(
    '04_omnibox',
    'Адресная строка и подсказки',
    '/?panel=omnibox&q=призм',
  ),
  _Screen('05_tabs', 'Переключатель вкладок', '/tabs'),
  _Screen('06_menu', 'Меню браузера', '/?panel=menu'),
  _Screen('07_privacy_sheet', 'Защита на сайте', '/?panel=privacy'),
  _Screen('08_settings', 'Настройки', '/settings'),
  _Screen('09_appearance', 'Настройки → Внешний вид', '/settings/appearance'),
  _Screen('10_privacy', 'Настройки → Приватность', '/settings/privacy'),
  _Screen('11_history', 'История', '/history'),
  _Screen('12_downloads', 'Загрузки', '/downloads'),
  _Screen('15_prism_search', 'Prism Search', '/', tab: 't6', search: 'призма'),
];

Future<ProviderContainer> _container(_Variant v, _Screen s) async {
  final c = await makeContainer(
    settings: AppearanceSettings(
      style: v.style,
      themeMode: v.mode,
      onboardingDone: !s.onboarding,
      useDynamicColor: false,
    ),
    location: s.location,
    progress: s.progress,
  );
  if (s.tab != null) c.read(tabsProvider.notifier).select(s.tab!);
  if (s.search != null) {
    c.read(browserActionsProvider).open(s.search!).ignore();
  }
  return c;
}

Widget _statusBar(bool dark) {
  final c = dark ? Colors.white : Colors.black;
  return IgnorePointer(
    child: SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            Text(
              '9:41',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
            const Spacer(),
            Icon(PrismIcons.cellSignal, size: 16, color: c),
            const SizedBox(width: 5),
            Icon(PrismIcons.wifi, size: 16, color: c),
            const SizedBox(width: 5),
            Icon(PrismIcons.battery, size: 20, color: c),
          ],
        ),
      ),
    ),
  );
}

Widget _device(
  ProviderContainer c,
  _Variant v,
  Size size, {
  required bool phone,
}) {
  final media = MediaQueryData(
    size: size,
    devicePixelRatio: 2,
    padding: phone
        ? const EdgeInsets.only(top: 47, bottom: 34)
        : EdgeInsets.zero,
    viewPadding: phone
        ? const EdgeInsets.only(top: 47, bottom: 34)
        : EdgeInsets.zero,
  );
  final screen = SizedBox.fromSize(
    size: size,
    child: MediaQuery(
      data: media,
      child: Stack(
        children: [
          Positioned.fill(
            child: UncontrolledProviderScope(
              container: c,
              child: const PrismApp(),
            ),
          ),
          if (phone) _statusBar(v.dark),
        ],
      ),
    ),
  );
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        v.label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
      ),
      const SizedBox(height: 18),
      Container(
        padding: EdgeInsets.all(phone ? 11 : 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2130),
          borderRadius: BorderRadius.circular(phone ? 56 : 18),
          border: Border.all(color: const Color(0xFF3A4157), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(phone ? 45 : 12),
          child: screen,
        ),
      ),
    ],
  );
}

Widget _board(
  String title,
  List<Widget> devices, {
  Axis axis = Axis.horizontal,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: _bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, 48, 64, 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prism Browser',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Flex(
              direction: axis,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < devices.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: axis == Axis.horizontal ? 48 : 0,
                      height: axis == Axis.vertical ? 48 : 0,
                    ),
                  devices[i],
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _render(
  WidgetTester tester,
  String file,
  Size boardSize,
  Widget board,
) async {
  tester.view.physicalSize = boardSize * 1.5;
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [const Locale('ru')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(key: const ValueKey('board'), child: board),
    ),
  );
  await tester.pumpAndSettle();
  // Second settle: sheets opened from post-frame callbacks animate in.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(const ValueKey('board')),
    matchesGoldenFile('boards/$file.png'),
  );
}

void main() {
  for (final s in _screens) {
    testWidgets('board ${s.file}', (tester) async {
      final devices = <Widget>[];
      for (final v in _variants) {
        final c = await _container(v, s);
        addTearDown(c.dispose);
        devices.add(_device(c, v, _phone, phone: true));
      }
      const w = 64 * 2 + 4 * (390 + 26) + 3 * 48.0;
      const h = 48 + 26 + 6 + 48 + 40 + 22 + 18 + 844 + 26 + 64 + 8.0;
      await _render(tester, s.file, const Size(w, h), _board(s.title, devices));
    });
  }

  for (final (file, title, style, location) in [
    ('13_desktop_glass', 'Windows · Liquid Glass', PrismStyleId.glass, '/'),
    ('14_desktop_material', 'Windows · Material 3', PrismStyleId.material, '/'),
  ]) {
    testWidgets('board $file', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final devices = <Widget>[];
      for (final v in _variants.where((v) => v.style == style)) {
        final c = await makeContainer(
          settings: AppearanceSettings(
            style: v.style,
            themeMode: v.mode,
            onboardingDone: true,
            useDynamicColor: false,
          ),
          location: location,
        );
        addTearDown(c.dispose);
        if (!v.dark) c.read(tabsProvider.notifier).select('t6');
        devices.add(_device(c, v, _desktop, phone: false));
      }
      const w = 64 * 2 + 1280 + 20.0;
      const h =
          48 + 26 + 6 + 48 + 40 + 2 * (22 + 18 + 800 + 20) + 48 + 64 + 8.0;
      await _render(
        tester,
        file,
        const Size(w, h),
        _board(title, devices, axis: Axis.vertical),
      );
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
