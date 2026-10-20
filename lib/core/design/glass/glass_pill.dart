import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// Tint family of a glass control.
enum GlassTone {
  /// Selected segment, primary button, active nav item: accent-tinted lens.
  accent,

  /// Secondary buttons, segmented track: clear glass.
  neutral,

  /// Destructive actions.
  danger,

  /// Inset track of a segmented control: slightly darker than the panel.
  recessed,
}

/// Resolved colors of a [GlassPill]. Kept separate from the widget so the
/// contrast test can verify foreground vs. composited fill.
@immutable
class GlassPillStyle {
  const GlassPillStyle({
    required this.fillTop,
    required this.fillBottom,
    required this.rimTop,
    required this.rimBottom,
    required this.sheen,
    required this.foreground,
  });

  final Color fillTop;
  final Color fillBottom;

  /// Bright edge where light enters the lens (top) fading to the bottom.
  final Color rimTop;
  final Color rimBottom;
  final Color sheen;

  /// Text / icon color drawn on this pill.
  final Color foreground;

  static GlassPillStyle resolve(PrismTokens t, GlassTone tone) {
    final dark = t.canvas.computeLuminance() < 0.5;
    const white = Color(0xFFFFFFFF);
    Color a(Color c, double alpha) => c.withValues(alpha: alpha);
    return switch (tone) {
      // Dark: clear, untinted glass (user request): emphasis comes from a
      // brighter lens, a strong rim and bold white text, not from hue.
      GlassTone.accent => GlassPillStyle(
        fillTop: dark ? a(white, 0.18) : a(t.accent, 0.18),
        fillBottom: dark ? a(white, 0.07) : a(t.accent, 0.10),
        rimTop: a(white, dark ? 0.75 : 0.95),
        rimBottom: dark ? a(white, 0.14) : a(t.accent, 0.40),
        sheen: a(white, dark ? 0.22 : 0.45),
        foreground: dark ? white : Color.lerp(t.accent, t.onSurface, 0.3)!,
      ),
      GlassTone.neutral => GlassPillStyle(
        fillTop: a(t.onSurface, dark ? 0.10 : 0.06),
        fillBottom: a(t.onSurface, dark ? 0.04 : 0.02),
        rimTop: a(white, dark ? 0.32 : 0.95),
        rimBottom: dark ? a(white, 0.06) : a(t.onSurface, 0.10),
        sheen: a(white, dark ? 0.08 : 0.40),
        foreground: t.onSurface,
      ),
      GlassTone.danger => GlassPillStyle(
        // Dark: clear glass too; only the label carries the danger color.
        fillTop: dark ? a(white, 0.10) : a(t.danger, 0.12),
        fillBottom: dark ? a(white, 0.04) : a(t.danger, 0.06),
        rimTop: a(white, dark ? 0.40 : 0.95),
        rimBottom: dark ? a(white, 0.06) : a(t.danger, 0.35),
        sheen: a(white, dark ? 0.10 : 0.40),
        foreground: dark
            ? Color.lerp(t.danger, white, 0.5)!
            : Color.lerp(t.danger, t.onSurface, 0.25)!,
      ),
      GlassTone.recessed => GlassPillStyle(
        fillTop: a(const Color(0xFF000000), dark ? 0.22 : 0.06),
        fillBottom: a(const Color(0xFF000000), dark ? 0.12 : 0.03),
        rimTop: a(white, dark ? 0.20 : 0.95),
        rimBottom: dark ? a(white, 0.06) : a(t.onSurface, 0.08),
        sheen: a(white, 0),
        foreground: t.onSurfaceMuted,
      ),
    };
  }
}

/// A tinted glass lens: gradient fill, luminous rim and top sheen.
///
/// It does not blur on its own: pills sit on surfaces that already blur
/// (bars, panels), and nested backdrop filters would double the cost and
/// the blur. [emphasis] (0..1) brightens the lens for hover/press feedback
/// and animates with [PrismMotion].
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.tone,
    this.child,
    this.emphasis = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
  });

  final GlassTone tone;
  final Widget? child;
  final double emphasis;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final style = GlassPillStyle.resolve(PrismTokens.of(context), tone);
    final motion = PrismMotion.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: emphasis),
      duration: motion.fast,
      curve: PrismMotion.enter,
      builder: (context, e, child) => CustomPaint(
        painter: _PillPainter(style: style, emphasis: e, radius: borderRadius),
        child: child,
      ),
      child: child,
    );
  }
}

class _PillPainter extends CustomPainter {
  _PillPainter({
    required this.style,
    required this.emphasis,
    required this.radius,
  });

  final GlassPillStyle style;
  final double emphasis;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    final boost = 1 + emphasis * 0.45;
    Color up(Color c) => c.withValues(alpha: (c.a * boost).clamp(0.0, 1.0));

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          up(style.fillTop),
          up(style.fillBottom),
        ]),
    );

    // Sheen: light caught in the upper half of the lens.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          Offset(rect.center.dx, rect.top + size.height * 0.6),
          [up(style.sheen), style.sheen.withValues(alpha: 0)],
        ),
    );

    // Luminous rim, brightest at the top edge.
    const w = 1.2;
    canvas.drawRRect(
      rrect.deflate(w / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          up(style.rimTop),
          style.rimBottom,
        ]),
    );
  }

  @override
  bool shouldRepaint(_PillPainter old) =>
      old.emphasis != emphasis ||
      old.radius != radius ||
      old.style.fillTop != style.fillTop ||
      old.style.fillBottom != style.fillBottom ||
      old.style.rimTop != style.rimTop ||
      old.style.rimBottom != style.rimBottom ||
      old.style.sheen != style.sheen;
}
