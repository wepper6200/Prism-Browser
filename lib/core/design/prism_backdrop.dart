import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Soft "light through a prism" wallpaper (start page, onboarding,
/// settings in Liquid Glass).
///
/// Performance (measured on transitions, see DECISIONES.md): painting three
/// full-screen radial gradients cost ~18 ms of raster per frame on both
/// routes during a page transition, because transforms invalidate the
/// raster cache. The wallpaper is smooth, so it is rendered once into a
/// tiny image (96 px wide) and scaled up with linear filtering: visually
/// identical, and drawing it is a single textured quad.
class PrismBackdrop extends StatelessWidget {
  const PrismBackdrop({super.key});

  static const _width = 96;
  static final _cache = <String, ui.Image>{};

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final dark = t.canvas.computeLuminance() < 0.5;
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        if (!size.isFinite || size.isEmpty) {
          return ColoredBox(color: t.canvas);
        }
        final image = _imageFor(t.canvas, t.accent, dark, size.aspectRatio);
        return RepaintBoundary(
          child: RawImage(
            image: image,
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        );
      },
    );
  }

  static ui.Image _imageFor(
    Color canvas,
    Color accent,
    bool dark,
    double aspect,
  ) {
    // Aspect bucketed to 0.05 so window resizes don't thrash the cache.
    final bucket = (aspect * 20).round() / 20;
    final key = '${canvas.toARGB32()}-${accent.toARGB32()}-$dark-$bucket';
    final cached = _cache[key];
    if (cached != null) return cached;

    final w = _width.toDouble();
    final h = (w / bucket).clamp(16.0, 512.0);
    final recorder = ui.PictureRecorder();
    _paint(Canvas(recorder), Size(w, h), canvas, accent, dark);
    final image = recorder.endRecording().toImageSync(w.round(), h.round());
    if (_cache.length >= 8) _cache.remove(_cache.keys.first);
    return _cache[key] = image;
  }

  static void _paint(
    Canvas c,
    Size size,
    Color canvas,
    Color accent,
    bool dark,
  ) {
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
}
