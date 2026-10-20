import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

/// 4-pt spacing scale. Not part of [PrismTokens] because spacing does not
/// change between styles (only density does, see [PrismDensity]).
abstract final class PrismSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Minimum interactive size (Material 48dp, also > Apple 44pt).
  static const double touch = 48;
}

/// Shared motion tokens. Use [PrismMotion.of] so "reduce motion" is honoured.
@immutable
class PrismMotion {
  const PrismMotion._(this._scale);

  final double _scale;

  static const _full = PrismMotion._(1);
  static const _none = PrismMotion._(0);

  bool get enabled => _scale > 0;

  /// Press feedback, hover, small state flips.
  Duration get fast => _d(120);

  /// Toggles, chips, icon morphs.
  Duration get medium => _d(220);

  /// Panels, sheets entering, omnibox morph.
  Duration get slow => _d(340);

  /// Large transforms: tab <-> page, style switch.
  Duration get emphasized => _d(500);

  /// Exits are ~65% of enter (MD motion guidance).
  Duration exitOf(Duration enter) =>
      Duration(microseconds: (enter.inMicroseconds * 0.65).round());

  static const Curve standard = Curves.easeInOutCubicEmphasized;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Light overshoot for "liquid" lenses that slide between positions.
  /// Implicit animations retarget mid-flight, so it stays interruptible.
  static const Curve spring = Cubic(0.34, 1.32, 0.64, 1);

  Duration _d(int ms) => Duration(milliseconds: (ms * _scale).round());

  static PrismMotion of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_MotionScope>();
    return (scope?.enabled ?? true) ? _full : _none;
  }

  static Widget scope({required bool enabled, required Widget child}) =>
      _MotionScope(enabled: enabled, child: child);
}

class _MotionScope extends InheritedWidget {
  const _MotionScope({required this.enabled, required super.child});

  final bool enabled;

  @override
  bool updateShouldNotify(_MotionScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Style-dependent design tokens. Registered as a [ThemeExtension] so that
/// switching style or brightness animates smoothly through [AnimatedTheme].
@immutable
class PrismTokens extends ThemeExtension<PrismTokens> {
  const PrismTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.secure,
    required this.warning,
    required this.danger,
    required this.incognito,
    required this.scrim,
    required this.glassTint,
    required this.glassBorderTop,
    required this.glassBorderBottom,
    required this.glassHighlight,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.blurSigma,
    required this.shadowOpacity,
  });

  /// Page/app background behind everything.
  final Color canvas;

  /// Default opaque surface (cards, lists). Also the glass fallback when
  /// transparency is reduced.
  final Color surface;
  final Color surfaceRaised;
  final Color onSurface;

  /// Secondary text. Always >= 4.5:1 against [surface] (checked in tests).
  final Color onSurfaceMuted;
  final Color outline;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  /// "Protected / HTTPS" status. Never used as the only signal: always
  /// paired with an icon and text.
  final Color secure;
  final Color warning;
  final Color danger;
  final Color incognito;
  final Color scrim;

  /// Glass material: tint over the blurred backdrop.
  final Color glassTint;
  final Color glassBorderTop;
  final Color glassBorderBottom;

  /// Specular highlight along the top edge.
  final Color glassHighlight;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  /// Backdrop blur sigma at full glass intensity. 0 for opaque styles.
  final double blurSigma;
  final double shadowOpacity;

  bool get isGlass => blurSigma > 0;

  static PrismTokens of(BuildContext context) =>
      Theme.of(context).extension<PrismTokens>()!;

  List<BoxShadow> shadow({double elevation = 1}) {
    if (shadowOpacity <= 0) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.6),
        blurRadius: 6 * elevation,
        offset: Offset(0, 1.5 * elevation),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.4),
        blurRadius: 24 * elevation,
        offset: Offset(0, 8 * elevation),
      ),
    ];
  }

  @override
  PrismTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? outline,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? secure,
    Color? warning,
    Color? danger,
    Color? incognito,
    Color? scrim,
    Color? glassTint,
    Color? glassBorderTop,
    Color? glassBorderBottom,
    Color? glassHighlight,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? blurSigma,
    double? shadowOpacity,
  }) {
    return PrismTokens(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      outline: outline ?? this.outline,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      secure: secure ?? this.secure,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      incognito: incognito ?? this.incognito,
      scrim: scrim ?? this.scrim,
      glassTint: glassTint ?? this.glassTint,
      glassBorderTop: glassBorderTop ?? this.glassBorderTop,
      glassBorderBottom: glassBorderBottom ?? this.glassBorderBottom,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      blurSigma: blurSigma ?? this.blurSigma,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
    );
  }

  @override
  PrismTokens lerp(PrismTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return PrismTokens(
      canvas: c(canvas, other.canvas),
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      onSurface: c(onSurface, other.onSurface),
      onSurfaceMuted: c(onSurfaceMuted, other.onSurfaceMuted),
      outline: c(outline, other.outline),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      accentSoft: c(accentSoft, other.accentSoft),
      secure: c(secure, other.secure),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      incognito: c(incognito, other.incognito),
      scrim: c(scrim, other.scrim),
      glassTint: c(glassTint, other.glassTint),
      glassBorderTop: c(glassBorderTop, other.glassBorderTop),
      glassBorderBottom: c(glassBorderBottom, other.glassBorderBottom),
      glassHighlight: c(glassHighlight, other.glassHighlight),
      radiusSm: d(radiusSm, other.radiusSm),
      radiusMd: d(radiusMd, other.radiusMd),
      radiusLg: d(radiusLg, other.radiusLg),
      radiusXl: d(radiusXl, other.radiusXl),
      blurSigma: d(blurSigma, other.blurSigma),
      shadowOpacity: d(shadowOpacity, other.shadowOpacity),
    );
  }
}

/// Inter-based type scale shared by all styles (12/14/16/18/22/28/34).
abstract final class PrismType {
  static const family = 'Inter';

  static TextTheme textTheme(Color onSurface, Color muted) {
    TextStyle s(
      double size,
      FontWeight w,
      double height, {
      double tracking = 0,
      Color? color,
    }) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: w,
      height: height,
      letterSpacing: tracking,
      color: color ?? onSurface,
    );
    return TextTheme(
      displayLarge: s(44, FontWeight.w700, 1.1, tracking: -1.2),
      displayMedium: s(34, FontWeight.w700, 1.15, tracking: -0.8),
      displaySmall: s(28, FontWeight.w700, 1.2, tracking: -0.5),
      headlineLarge: s(28, FontWeight.w600, 1.25, tracking: -0.4),
      headlineMedium: s(24, FontWeight.w600, 1.25, tracking: -0.3),
      headlineSmall: s(22, FontWeight.w600, 1.3, tracking: -0.2),
      titleLarge: s(20, FontWeight.w600, 1.3, tracking: -0.2),
      titleMedium: s(16, FontWeight.w600, 1.4),
      titleSmall: s(14, FontWeight.w600, 1.4),
      bodyLarge: s(16, FontWeight.w400, 1.5),
      bodyMedium: s(14, FontWeight.w400, 1.5),
      bodySmall: s(12, FontWeight.w400, 1.45, color: muted),
      labelLarge: s(14, FontWeight.w500, 1.3, tracking: 0.1),
      labelMedium: s(12, FontWeight.w500, 1.3, tracking: 0.3),
      labelSmall: s(11, FontWeight.w600, 1.3, tracking: 0.8, color: muted),
    );
  }
}

/// Height and padding of bars depending on [UiDensity].
@immutable
class PrismDensity {
  const PrismDensity({required this.barHeight, required this.listTileHeight});

  static const comfortable = PrismDensity(barHeight: 56, listTileHeight: 56);
  static const compact = PrismDensity(barHeight: 48, listTileHeight: 48);

  final double barHeight;
  final double listTileHeight;
}
