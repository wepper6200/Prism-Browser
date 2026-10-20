import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/settings/appearance_repository.dart';
import '../../domain/settings/appearance.dart';

/// Preloaded in `main()` and overridden in [ProviderScope].
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final appearanceRepositoryProvider = Provider<AppearanceRepository>(
  (ref) => AppearanceRepository(ref.watch(sharedPreferencesProvider)),
);

final appearanceProvider =
    NotifierProvider<AppearanceController, AppearanceSettings>(
      AppearanceController.new,
    );

class AppearanceController extends Notifier<AppearanceSettings> {
  @override
  AppearanceSettings build() {
    final bar = defaultTargetPlatform == TargetPlatform.android
        ? AddressBarPosition.bottom
        : AddressBarPosition.top;
    return ref.read(appearanceRepositoryProvider).load(defaultBar: bar);
  }

  void update(AppearanceSettings Function(AppearanceSettings) change) {
    final next = change(state);
    if (next == state) return;
    state = next;
    // Fire-and-forget: UI already reflects the new value; prefs write is
    // async and must not block the frame.
    ref.read(appearanceRepositoryProvider).save(next).ignore();
  }

  void setStyle(PrismStyleId v) => update((s) => s.copyWith(style: v));
  void setThemeMode(PrismThemeMode v) =>
      update((s) => s.copyWith(themeMode: v));
  void setGlassMode(GlassMode v) => update((s) => s.copyWith(glassMode: v));
  void setGlassIntensity(double v) =>
      update((s) => s.copyWith(glassIntensity: v, glassMode: GlassMode.manual));
  void setReduceMotion(bool v) => update((s) => s.copyWith(reduceMotion: v));
  void setSeed(int argb) =>
      update((s) => s.copyWith(seedColor: argb, useDynamicColor: false));
  void setDynamicColor(bool v) => update((s) => s.copyWith(useDynamicColor: v));
  void setAddressBar(AddressBarPosition v) =>
      update((s) => s.copyWith(addressBarPosition: v));
  void setDensity(UiDensity v) => update((s) => s.copyWith(density: v));
  void completeOnboarding() => update((s) => s.copyWith(onboardingDone: true));
}
