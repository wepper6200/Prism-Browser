import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/settings/appearance_controller.dart';
import '../../core/design/design_registry.dart';
import '../../core/design/effects_policy.dart';
import '../../core/design/prism_design.dart';
import '../../core/design/tokens.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';
import 'router.dart';

class PrismApp extends ConsumerWidget {
  const PrismApp({super.key, this.home});

  /// When set, shows this widget instead of the router (widget tests).
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appearanceProvider);
    final design = designFor(s.style);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        Color seedFor(ColorScheme? dyn) =>
            (s.useDynamicColor ? dyn?.primary : null) ?? Color(s.seedColor);

        ThemeData theme(Brightness b, ColorScheme? dyn) => design.buildTheme(
          PrismThemeInput(
            brightness: b,
            seed: seedFor(dyn),
            density: s.density,
          ),
        );

        final light = theme(Brightness.light, lightDynamic);
        final dark = theme(Brightness.dark, darkDynamic);
        final mode = switch (s.themeMode) {
          PrismThemeMode.system => ThemeMode.system,
          PrismThemeMode.light => ThemeMode.light,
          PrismThemeMode.dark => ThemeMode.dark,
        };
        // Style/theme switches lerp all PrismTokens (colors, radii, blur).
        final animation = s.reduceMotion
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 500),
                curve: PrismMotion.standard,
              );
        // Generated AppLocalizations.localizationsDelegates still point to
        // the framework's legacy Material localizations; material_ui
        // widgets need material_ui's own delegates.
        const delegates = [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ];
        Widget scopes(BuildContext context, Widget? child) {
          final policy = EffectsPolicy.resolve(
            settings: s,
            systemDisableAnimations: MediaQuery.disableAnimationsOf(context),
            systemHighContrast: MediaQuery.highContrastOf(context),
          );
          return PrismDesignScope(
            design: design,
            child: EffectsScope(
              policy: policy,
              child: PrismMotion.scope(
                enabled: policy.animations,
                child: child!,
              ),
            ),
          );
        }

        if (home != null) {
          return MaterialApp(
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: mode,
            themeAnimationStyle: animation,
            localizationsDelegates: delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: scopes,
            home: home,
          );
        }
        return MaterialApp.router(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
          themeMode: mode,
          themeAnimationStyle: animation,
          localizationsDelegates: delegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: scopes,
          routerConfig: ref.watch(routerProvider),
        );
      },
    );
  }
}
