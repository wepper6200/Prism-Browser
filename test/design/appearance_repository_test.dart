import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/data/settings/appearance_repository.dart';
import 'package:prism_browser/domain/settings/appearance.dart';

import '../helpers/pump_app.dart';

void main() {
  test('fresh install: dark theme, glass, platform address bar', () async {
    final repo = AppearanceRepository(await freshPrefs());
    final s = repo.load(defaultBar: AddressBarPosition.bottom);
    expect(s.themeMode, PrismThemeMode.dark);
    expect(s.style, PrismStyleId.glass);
    expect(s.addressBarPosition, AddressBarPosition.bottom);
    expect(s.onboardingDone, isFalse);
  });

  test('round-trips every field', () async {
    final prefs = await freshPrefs();
    const s = AppearanceSettings(
      style: PrismStyleId.material,
      themeMode: PrismThemeMode.light,
      useDynamicColor: false,
      seedColor: 0xFF22C55E,
      addressBarPosition: AddressBarPosition.top,
      density: UiDensity.compact,
      glassMode: GlassMode.manual,
      glassIntensity: 0.3,
      reduceMotion: true,
      onboardingDone: true,
    );
    await AppearanceRepository(prefs).save(s);
    expect(
      AppearanceRepository(prefs).load(defaultBar: AddressBarPosition.bottom),
      s,
    );
  });

  test('unknown stored enum falls back to default', () async {
    final prefs = await freshPrefs();
    await prefs.setString('appearance.style', 'holographic');
    final s = AppearanceRepository(prefs)
        .load(defaultBar: AddressBarPosition.top);
    expect(s.style, PrismStyleId.glass);
  });
}
