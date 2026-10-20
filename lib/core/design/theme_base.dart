import 'package:material_ui/material_ui.dart';

import '../../domain/settings/appearance.dart';
import 'tokens.dart';

/// ThemeData pieces shared by every style, so Material widgets that appear
/// inside any style (switches, sliders, text fields, focus) stay consistent.
ThemeData buildBaseTheme({
  required ColorScheme scheme,
  required PrismTokens tokens,
  required UiDensity density,
  required InteractiveInkFeatureFactory splashFactory,
}) {
  final text = PrismType.textTheme(tokens.onSurface, tokens.onSurfaceMuted);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: scheme.brightness,
    fontFamily: PrismType.family,
    textTheme: text,
    scaffoldBackgroundColor: tokens.canvas,
    canvasColor: tokens.canvas,
    splashFactory: splashFactory,
    visualDensity: density == UiDensity.compact
        ? VisualDensity.compact
        : VisualDensity.standard,
    // Touch targets stay >= 48dp even in compact density.
    materialTapTargetSize: MaterialTapTargetSize.padded,
    focusColor: tokens.accent.withValues(alpha: 0.24),
    iconTheme: IconThemeData(color: tokens.onSurface, size: 22),
    dividerTheme: DividerThemeData(color: tokens.outline, thickness: 1),
    // Forms: filled fields, visible label above, clear focus and error.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.onSurface.withValues(alpha: 0.06),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: text.labelLarge?.copyWith(color: tokens.onSurfaceMuted),
      floatingLabelStyle: text.labelLarge?.copyWith(color: tokens.onSurface),
      hintStyle: text.bodyLarge?.copyWith(color: tokens.onSurfaceMuted),
      helperStyle: text.bodySmall,
      helperMaxLines: 3,
      errorStyle: text.bodySmall?.copyWith(color: tokens.danger),
      errorMaxLines: 3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: tokens.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: tokens.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: tokens.onSurface, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: tokens.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide(color: tokens.danger, width: 2),
      ),
    ),
    // 3 segments must fit a 360dp phone without wrapping labels.
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8),
        ),
        iconSize: const WidgetStatePropertyAll(18),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 500),
      textStyle: text.bodySmall?.copyWith(color: tokens.surface),
      decoration: BoxDecoration(
        color: tokens.onSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Android 14+ predictive back; Windows gets a fade-through.
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    extensions: [tokens],
  );
}

/// Visible keyboard focus ring for custom buttons (WCAG 2.4.7 / 2.4.11).
WidgetStateProperty<BorderSide?> focusRing(PrismTokens t, {BorderSide? idle}) =>
    WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(color: t.accent, width: 2);
      }
      return idle;
    });
