import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/settings/appearance.dart';

/// Persists [AppearanceSettings] in shared_preferences. Reads are synchronous
/// (prefs are preloaded before `runApp`) so the first frame already has the
/// right theme and there is no flash of the wrong style.
class AppearanceRepository {
  AppearanceRepository(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _kStyle = 'appearance.style';
  static const _kTheme = 'appearance.themeMode';
  static const _kDynamic = 'appearance.dynamicColor';
  static const _kSeed = 'appearance.seed';
  static const _kBar = 'appearance.addressBar';
  static const _kDensity = 'appearance.density';
  static const _kGlassMode = 'appearance.glassMode';
  static const _kGlassIntensity = 'appearance.glassIntensity';
  static const _kReduceMotion = 'appearance.reduceMotion';
  static const _kOnboarding = 'appearance.onboardingDone';

  static const allKeys = {
    _kStyle,
    _kTheme,
    _kDynamic,
    _kSeed,
    _kBar,
    _kDensity,
    _kGlassMode,
    _kGlassIntensity,
    _kReduceMotion,
    _kOnboarding,
  };

  AppearanceSettings load({required AddressBarPosition defaultBar}) {
    const d = AppearanceSettings();
    return AppearanceSettings(
      style: _enum(PrismStyleId.values, _prefs.getString(_kStyle), d.style),
      themeMode: _enum(
        PrismThemeMode.values,
        _prefs.getString(_kTheme),
        d.themeMode,
      ),
      useDynamicColor: _prefs.getBool(_kDynamic) ?? d.useDynamicColor,
      seedColor: _prefs.getInt(_kSeed) ?? d.seedColor,
      addressBarPosition: _enum(
        AddressBarPosition.values,
        _prefs.getString(_kBar),
        defaultBar,
      ),
      density: _enum(UiDensity.values, _prefs.getString(_kDensity), d.density),
      glassMode: _enum(
        GlassMode.values,
        _prefs.getString(_kGlassMode),
        d.glassMode,
      ),
      glassIntensity: (_prefs.getDouble(_kGlassIntensity) ?? d.glassIntensity)
          .clamp(0, 1),
      reduceMotion: _prefs.getBool(_kReduceMotion) ?? d.reduceMotion,
      onboardingDone: _prefs.getBool(_kOnboarding) ?? d.onboardingDone,
    );
  }

  Future<void> save(AppearanceSettings s) async {
    await Future.wait([
      _prefs.setString(_kStyle, s.style.name),
      _prefs.setString(_kTheme, s.themeMode.name),
      _prefs.setBool(_kDynamic, s.useDynamicColor),
      _prefs.setInt(_kSeed, s.seedColor),
      _prefs.setString(_kBar, s.addressBarPosition.name),
      _prefs.setString(_kDensity, s.density.name),
      _prefs.setString(_kGlassMode, s.glassMode.name),
      _prefs.setDouble(_kGlassIntensity, s.glassIntensity),
      _prefs.setBool(_kReduceMotion, s.reduceMotion),
      _prefs.setBool(_kOnboarding, s.onboardingDone),
    ]);
  }

  static T _enum<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
