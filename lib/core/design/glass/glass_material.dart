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
    this.blur = true,
  });

  /// False for content surfaces (cards) that sit on the already-soft Prism
  /// backdrop: a backdrop blur there is visually near-identical but costs a
  /// full offscreen pass per surface per frame (measured: 138 ms raster
  /// per transition frame in Glass vs 20 ms in Material). Tint, rim and
  /// highlight stay, so the material still reads as glass.
  final bool blur;

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
    // Live backdrop blur is the most expensive thing on screen (~22 ms of
    // raster per bar per frame measured on transitions). While the page
    // route is animating, the page content under the bar moves anyway, so
    // a denser tint is used instead and the blur returns when it settles.
    final route = ModalRoute.of(context);
    if (blur && route is PageRoute) {
      return _RouteMotion(
        route: route,
        builder: (moving) => _compose(context, liveBlur: !moving),
      );
    }
    return _compose(context, liveBlur: blur);
  }

  Widget _compose(BuildContext context, {required bool liveBlur}) {
    final t = PrismTokens.of(context);
    final fx = EffectsPolicy.of(context);
    final strength = fx.glassStrength;
    // Without the blur, a little more tint keeps text on the bar readable.
    final compensate = blur && !liveBlur ? 0.25 : 0.0;

    final painter = _GlassPainter(
      radius: borderRadius,
      tint: strength > 0
          ? _boost(t.glassTint, tintBoost + compensate + (1 - strength) * 0.6)
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

    if (liveBlur && strength > 0 && t.blurSigma > 0) {
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

    if (shadow && t.shadowOpacity > 0) {
      // BlurStyle.outer: the shadow is drawn only outside the shape, so it
      // lifts the glass without darkening its see-through middle.
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000)
                  .withValues(alpha: t.shadowOpacity * 0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: body,
      );
    }
    return body;
  }

  static Color _boost(Color c, double extra) =>
      c.withValues(alpha: (c.a + extra).clamp(0.0, 1.0));
}

/// Rebuilds only when the page route starts/stops moving (its own
/// push/pop animation or the one of the route covering it), never per
/// animation tick.
class _RouteMotion extends StatefulWidget {
  const _RouteMotion({required this.route, required this.builder});

  final PageRoute<dynamic> route;
  final Widget Function(bool moving) builder;

  @override
  State<_RouteMotion> createState() => _RouteMotionState();
}

class _RouteMotionState extends State<_RouteMotion> {
  Animation<double>? _a;
  Animation<double>? _b;
  bool _moving = false;

  static bool _isMoving(Animation<double>? a) =>
      a != null &&
      (a.status == AnimationStatus.forward ||
          a.status == AnimationStatus.reverse);

  bool get _now => _isMoving(_a) || _isMoving(_b);

  void _onStatus(AnimationStatus _) {
    final m = _now;
    if (m != _moving && mounted) setState(() => _moving = m);
  }

  void _attach() {
    _a = widget.route.animation?..addStatusListener(_onStatus);
    _b = widget.route.secondaryAnimation?..addStatusListener(_onStatus);
    _moving = _now;
  }

  void _detach() {
    _a?.removeStatusListener(_onStatus);
    _b?.removeStatusListener(_onStatus);
  }

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(_RouteMotion old) {
    super.didUpdateWidget(old);
    if (old.route != widget.route) {
      _detach();
      _attach();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_moving);
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
    const white = Color(0xFFFFFFFF);

    // Body: the tint is a touch lighter at the top, like light falling on
    // a slab of glass.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          Color.lerp(tint, white.withValues(alpha: tint.a), 0.06)!,
          tint,
        ]),
    );

    if (highlight.a > 0) {
      // Specular sheen: strongest at the top edge, gone by ~55% height.
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            Offset(rect.center.dx, rect.top + size.height * 0.55),
            [highlight, highlight.withValues(alpha: 0)],
          ),
      );
      // Light bounced back through the glass along the bottom edge.
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.bottomCenter,
            Offset(rect.center.dx, rect.bottom - size.height * 0.35),
            [
              highlight.withValues(alpha: highlight.a * 0.45),
              highlight.withValues(alpha: 0),
            ],
          ),
      );
    }

    // Outer rim: diagonal light, brightest at the top-left.
    final inset = borderWidth / 2;
    canvas.drawRRect(
      rrect.deflate(inset),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [borderTop, Color.lerp(borderTop, borderBottom, 0.7)!, borderBottom],
          const [0, 0.5, 1],
        ),
    );

    // Inner rim: a fainter second edge reads as glass thickness.
    if (highlight.a > 0 && size.shortestSide > 24) {
      canvas.drawRRect(
        rrect.deflate(borderWidth + 1.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            [
              highlight.withValues(alpha: highlight.a * 0.55),
              highlight.withValues(alpha: 0),
              highlight.withValues(alpha: highlight.a * 0.25),
            ],
            const [0, 0.45, 1],
          ),
      );
    }
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
