import 'package:flutter/foundation.dart';

/// Visual style of the whole interface. New styles are registered in
/// `lib/core/design/design_registry.dart`; screens never switch on this enum.
enum PrismStyleId { glass, material }

enum PrismThemeMode { system, light, dark }

enum AddressBarPosition { top, bottom }

enum UiDensity { comfortable, compact }

/// How strong glass effects are. [auto] lets [EffectsPolicy] decide based on
/// device capabilities and accessibility settings.
enum GlassMode { auto, manual, off }

@immutable
class AppearanceSettings {
  const AppearanceSettings({
    this.style = PrismStyleId.glass,
    this.themeMode = PrismThemeMode.dark,
    this.useDynamicColor = true,
    this.seedColor = defaultSeed,
    this.addressBarPosition = AddressBarPosition.top,
    this.density = UiDensity.comfortable,
    this.glassMode = GlassMode.auto,
    this.glassIntensity = 1.0,
    this.reduceMotion = false,
    this.onboardingDone = false,
  });

  /// Prism violet: brand accent, also the Material seed when dynamic color
  /// is unavailable or disabled.
  static const int defaultSeed = 0xFF7C6CF2;

  final PrismStyleId style;
  final PrismThemeMode themeMode;
  final bool useDynamicColor;
  final int seedColor;
  final AddressBarPosition addressBarPosition;
  final UiDensity density;
  final GlassMode glassMode;

  /// 0..1, used only when [glassMode] is [GlassMode.manual].
  final double glassIntensity;
  final bool reduceMotion;
  final bool onboardingDone;

  AppearanceSettings copyWith({
    PrismStyleId? style,
    PrismThemeMode? themeMode,
    bool? useDynamicColor,
    int? seedColor,
    AddressBarPosition? addressBarPosition,
    UiDensity? density,
    GlassMode? glassMode,
    double? glassIntensity,
    bool? reduceMotion,
    bool? onboardingDone,
  }) {
    return AppearanceSettings(
      style: style ?? this.style,
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      seedColor: seedColor ?? this.seedColor,
      addressBarPosition: addressBarPosition ?? this.addressBarPosition,
      density: density ?? this.density,
      glassMode: glassMode ?? this.glassMode,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.style == style &&
      other.themeMode == themeMode &&
      other.useDynamicColor == useDynamicColor &&
      other.seedColor == seedColor &&
      other.addressBarPosition == addressBarPosition &&
      other.density == density &&
      other.glassMode == glassMode &&
      other.glassIntensity == glassIntensity &&
      other.reduceMotion == reduceMotion &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(
    style,
    themeMode,
    useDynamicColor,
    seedColor,
    addressBarPosition,
    density,
    glassMode,
    glassIntensity,
    reduceMotion,
    onboardingDone,
  );
}
