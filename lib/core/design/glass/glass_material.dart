import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../effects_policy.dart';
import '../tokens.dart';

/// Base glass material: backdrop blur + tint + specular top highlight +
/// gradient hairline border.
///
/// Stage 6 adds a FragmentProgram pass (edge lensing, chromatic offset,
/// adaptive tint). When [EffectsPolicy.glassStrength] is 0 (reduce
/// transparency, high contrast, Glass "Off", low-end device) it degrades to
/// an opaque surface with the same shape and border, so layout and contrast
/// never depend on blur.
class GlassMaterial extends StatelessWidget {
  const GlassMaterial({
    super.key,
    required this.borderRadius,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.tintBoost = 0,
    this.borderColor,
    this.borderWidth = 1,
    this.shadow = false,
  });

  final BorderRadius borderRadius;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Extra tint opacity (0..1) for surfaces that carry dense text (menus).
  final double tintBoost;

  /// Overrides the gradient border (e.g. accent border for selected cards).
  final Color? borderColor;
  final double borderWidth;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final fx = EffectsPolicy.of(context);
    final strength = fx.glassStrength;

    final painter = _GlassPainter(
      radius: borderRadius,
      tint: strength > 0
          ? _boost(t.glassTint, tintBoost + (1 - strength) * 0.6)
          : t.surfaceRaised,
      highlight: t.glassHighlight.withValues(
        alpha: t.glassHighlight.a * strength,
      ),
      borderTop: borderColor ?? t.glassBorderTop,
      borderBottom: borderColor ?? t.glassBorderBottom,
      borderWidth: borderWidth,
    );

    Widget body = CustomPaint(
      painter: painter,
      child: Padding(padding: padding, child: child),
    );

    if (strength > 0 && t.blurSigma > 0) {
      final sigma = t.blurSigma * strength;
      body = ClipRRect(
        borderRadius: borderRadius,
        // Plain (ungrouped) filter: grouped filters must not overlap, and
        // sheets/menus overlap bars. Grouping is a stage-7 optimisation,
        // to be accepted only with before/after measurements.
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.mirror,
          ),
          child: body,
        ),
      );
    }

    if (shadow) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: t.shadow(elevation: 1.2),
        ),
        child: body,
      );
    }
    return body;
  }

  static Color _boost(Color c, double extra) =>
      c.withValues(alpha: (c.a + extra).clamp(0.0, 1.0));
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.radius,
    required this.tint,
    required this.highlight,
    required this.borderTop,
    required this.borderBottom,
    required this.borderWidth,
  });

  final BorderRadius radius;
  final Color tint;
  final Color highlight;
  final Color borderTop;
  final Color borderBottom;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);

    canvas.drawRRect(rrect, Paint()..color = tint);

    if (highlight.a > 0) {
      // Specular sheen: strongest at the top edge, gone by ~55% height.
      final sheen = Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          Offset(rect.center.dx, rect.top + size.height * 0.55),
          [highlight, highlight.withValues(alpha: 0)],
        );
      canvas.drawRRect(rrect, sheen);
    }

    final inset = borderWidth / 2;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
        borderTop,
        borderBottom,
      ]);
    canvas.drawRRect(rrect.deflate(inset), border);
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.tint != tint ||
      old.highlight != highlight ||
      old.borderTop != borderTop ||
      old.borderBottom != borderBottom ||
      old.borderWidth != borderWidth ||
      old.radius != radius;
}
