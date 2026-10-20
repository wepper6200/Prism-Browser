import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/core/design/effects_policy.dart';
import 'package:prism_browser/domain/settings/appearance.dart';

void main() {
  EffectsPolicy resolve(
    AppearanceSettings s, {
    bool anim = false,
    bool hc = false,
    DeviceCapabilities caps = const DeviceCapabilities(),
  }) => EffectsPolicy.resolve(
    settings: s,
    systemDisableAnimations: anim,
    systemHighContrast: hc,
    caps: caps,
  );

  test('defaults: full glass and animations', () {
    final p = resolve(const AppearanceSettings());
    expect(p.glassStrength, 1);
    expect(p.animations, isTrue);
  });

  test('Glass Off and manual intensity', () {
    expect(
      resolve(const AppearanceSettings(glassMode: GlassMode.off)).blurEnabled,
      isFalse,
    );
    expect(
      resolve(
        const AppearanceSettings(
          glassMode: GlassMode.manual,
          glassIntensity: 0.4,
        ),
      ).glassStrength,
      0.4,
    );
  });

  test('system high contrast / reduce transparency force opaque glass', () {
    const manual = AppearanceSettings(glassMode: GlassMode.manual);
    expect(resolve(manual, hc: true).glassStrength, 0);
    expect(
      resolve(
        manual,
        caps: const DeviceCapabilities(systemReduceTransparency: true),
      ).glassStrength,
      0,
    );
  });

  test('auto mode degrades on low-end and power save', () {
    const s = AppearanceSettings();
    expect(
      resolve(
        s,
        caps: const DeviceCapabilities(lowEndDevice: true),
      ).glassStrength,
      0,
    );
    final saver = resolve(
      s,
      caps: const DeviceCapabilities(powerSaveMode: true),
    );
    expect(saver.glassStrength, 0);
    expect(saver.animations, isFalse);
  });

  test('reduce motion: app setting or system flag', () {
    expect(
      resolve(const AppearanceSettings(reduceMotion: true)).animations,
      isFalse,
    );
    expect(resolve(const AppearanceSettings(), anim: true).animations, isFalse);
  });
}
