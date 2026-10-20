import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Rendering of [FakeEngine] pages (tests, showcase, hosts without a web
/// engine): a light article page, as most of the web is, so chrome can be
/// judged over realistic content. Own text, not a copy of any site.
class MockWebPage extends StatelessWidget {
  const MockWebPage({
    super.key,
    required this.topInset,
    required this.bottomInset,
    this.controller,
  });

  final double topInset;
  final double bottomInset;
  final ScrollController? controller;

  static const _ink = Color(0xFF202122);
  static const _muted = Color(0xFF54595D);
  static const _bodyStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.6,
    color: _ink,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, c) {
          // Like real article pages: a readable column centred when wide.
          final side = c.maxWidth > 800 ? (c.maxWidth - 760) / 2 : 0.0;
          return _page(side);
        },
      ),
    );
  }

  Widget _page(double side) {
    const body = _bodyStyle;
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(side, topInset, side, bottomInset + 24),
      children: const [
        _SiteHeader(),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
          child: Text(
            'Призма (оптика)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Материал из Википедии — свободной энциклопедии',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _muted),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: CustomPaint(painter: _PrismPainter(), size: Size.infinite),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Text(
            'Дисперсия белого света в треугольной призме',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _muted),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Оптическая призма — прозрачное тело с плоскими гранями, '
            'которое преломляет проходящий через него свет. Показатель '
            'преломления стекла зависит от длины волны, поэтому лучи '
            'разного цвета отклоняются на разные углы, и белый свет '
            'раскладывается в спектр.\n\n'
            'Это явление называют дисперсией. Его используют в '
            'спектрометрах, перископах и биноклях, а в фотографии и '
            'дизайне призма давно стала символом ясности и разложения '
            'сложного на простые составляющие.',
            style: body,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            'Устройство',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Чаще всего встречаются треугольные призмы из оптического '
            'стекла или кварца. Угол между преломляющими гранями '
            'определяет, насколько сильно отклонится луч, а материал — '
            'насколько широким получится спектр.',
            style: body,
          ),
        ),
      ],
    );
  }
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: const Text(
        'ВИКИПЕДИЯ · Свободная энциклопедия',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: MockWebPage._muted,
        ),
      ),
    );
  }
}

class _PrismPainter extends CustomPainter {
  const _PrismPainter();

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, s.height), const [
          Color(0xFF0B1020),
          Color(0xFF151B33),
        ]),
    );
    final cx = s.width * 0.45;
    final top = Offset(cx, s.height * 0.18);
    final left = Offset(cx - s.height * 0.38, s.height * 0.82);
    final right = Offset(cx + s.height * 0.38, s.height * 0.82);
    final hit = Offset.lerp(top, left, 0.5)!;
    final exit = Offset.lerp(top, right, 0.55)!;

    canvas.drawLine(
      Offset(0, s.height * 0.62),
      hit,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      hit,
      exit,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 2.5,
    );
    const spectrum = [
      Color(0xFFFF3B30),
      Color(0xFFFF9500),
      Color(0xFFFFE600),
      Color(0xFF34C759),
      Color(0xFF00C7FF),
      Color(0xFF5856D6),
      Color(0xFFAF52DE),
    ];
    for (var i = 0; i < spectrum.length; i++) {
      final a = -0.18 + i * 0.075;
      final end = exit + Offset(math.cos(a), math.sin(a)) * s.width;
      final path = Path()
        ..moveTo(exit.dx, exit.dy)
        ..lineTo(end.dx, end.dy - 6)
        ..lineTo(end.dx, end.dy + 12)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = spectrum[i].withValues(alpha: 0.85),
      );
    }
    final prism = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(
      prism,
      Paint()
        ..shader = ui.Gradient.linear(top, Offset(cx, right.dy), [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.08),
        ]),
    );
    canvas.drawPath(
      prism,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(_PrismPainter oldDelegate) => false;
}
