import 'package:flutter/widgets.dart';

import '../../domain/settings/appearance.dart';

/// What we know about the device that affects visual effects.
///
/// Stage 1: only what Flutter exposes directly (MediaQuery). Detection of
/// battery saver, low-RAM devices and the Windows "Transparency effects" /
/// system "reduce transparency" switch arrives in stage 6 via a platform
/// channel; until then these flags stay `false` (honest "unknown").
@immutable
class DeviceCapabilities {
  const DeviceCapabilities({
    this.lowEndDevice = false,
    this.powerSaveMode = false,
    this.systemReduceTransparency = false,
  });

  final bool lowEndDevice;
  final bool powerSaveMode;
  final bool systemReduceTransparency;
}

/// Resolved, effective visual effects for the current frame.
@immutable
class EffectsPolicy {
  const EffectsPolicy({
    required this.glassStrength,
    required this.animations,
    required this.highContrast,
  });

  static const full = EffectsPolicy(
    glassStrength: 1,
    animations: true,
    highContrast: false,
  );

  /// 0 = opaque fallback, 1 = full blur/tint/highlights.
  final double glassStrength;
  final bool animations;
  final bool highContrast;

  bool get blurEnabled => glassStrength > 0.01;

  /// Chrome floating over content the backdrop filter cannot sample (web
  /// view in Hybrid Composition): glass would show sharp, unreadable page
  /// text through the tint, so it degrades to the opaque surface.
  EffectsPolicy overUnblurrableContent() => EffectsPolicy(
    glassStrength: 0,
    animations: animations,
    highContrast: highContrast,
  );

  static EffectsPolicy resolve({
    required AppearanceSettings settings,
    required bool systemDisableAnimations,
    required bool systemHighContrast,
    DeviceCapabilities caps = const DeviceCapabilities(),
  }) {
    final double strength;
    if (systemHighContrast || caps.systemReduceTransparency) {
      strength = 0;
    } else {
      switch (settings.glassMode) {
        case GlassMode.off:
          strength = 0;
        case GlassMode.manual:
          strength = settings.glassIntensity;
        case GlassMode.auto:
          strength = caps.lowEndDevice || caps.powerSaveMode ? 0.0 : 1.0;
      }
    }
    return EffectsPolicy(
      glassStrength: strength,
      animations:
          !(settings.reduceMotion ||
              systemDisableAnimations ||
              caps.powerSaveMode),
      highContrast: systemHighContrast,
    );
  }

  static EffectsPolicy of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EffectsScope>()?.policy ??
      full;

  @override
  bool operator ==(Object other) =>
      other is EffectsPolicy &&
      other.glassStrength == glassStrength &&
      other.animations == animations &&
      other.highContrast == highContrast;

  @override
  int get hashCode => Object.hash(glassStrength, animations, highContrast);
}

class EffectsScope extends InheritedWidget {
  const EffectsScope({super.key, required this.policy, required super.child});

  final EffectsPolicy policy;

  @override
  bool updateShouldNotify(EffectsScope oldWidget) => policy != oldWidget.policy;
}
