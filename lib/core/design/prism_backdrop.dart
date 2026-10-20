import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Soft "light through a prism" wallpaper used on the start page, onboarding
/// and the design gallery. Static, so it is painted once and cached by the
/// [RepaintBoundary]; glass panels blur this cached layer.
class PrismBackdrop extends StatelessWidget {
  const PrismBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final dark = t.canvas.computeLuminance() < 0.5;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PrismPainter(canvas: t.canvas, accent: t.accent, dark: dark),
        size: Size.infinite,
      ),
    );
  }
}

class _PrismPainter extends CustomPainter {
  _PrismPainter({
    required this.canvas,
    required this.accent,
    required this.dark,
  });

  final Color canvas;
  final Color accent;
  final bool dark;

  @override
  void paint(Canvas c, Size size) {
    c.drawRect(Offset.zero & size, Paint()..color = canvas);
    final a = dark ? 0.55 : 0.35;
    final shortest = size.shortestSide;
    void blob(Offset center, double r, Color color) {
      c.drawCircle(
        center,
        r,
        Paint()
          ..shader = ui.Gradient.radial(center, r, [
            color.withValues(alpha: a),
            color.withValues(alpha: 0),
          ]),
      );
    }

    blob(Offset(size.width * 0.15, size.height * 0.12), shortest * 0.9, accent);
    blob(
      Offset(size.width * 0.95, size.height * 0.35),
      shortest * 0.8,
      const Color(0xFF22D3EE),
    );
    blob(
      Offset(size.width * 0.35, size.height * 0.95),
      shortest * 0.85,
      const Color(0xFFF472B6),
    );
  }

  @override
  bool shouldRepaint(_PrismPainter old) =>
      old.canvas != canvas || old.accent != accent || old.dark != dark;
}
