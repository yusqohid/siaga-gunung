import 'package:flutter/material.dart';

/// Line icons that mirror the SVG paths used in the prototype navigation.
enum NavGlyph { home, map, volcano, book, checklist }

class NavGlyphIcon extends StatelessWidget {
  final NavGlyph glyph;
  final double size;
  final Color color;

  const NavGlyphIcon({
    super.key,
    required this.glyph,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NavGlyphPainter(
          glyph: glyph,
          color: color,
          strokeWidth: 1.7,
        ),
      ),
    );
  }
}

class _NavGlyphPainter extends CustomPainter {
  final NavGlyph glyph;
  final Color color;
  final double strokeWidth;

  const _NavGlyphPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    switch (glyph) {
      case NavGlyph.home:
        path.moveTo(3, 11);
        path.lineTo(12, 3);
        path.lineTo(21, 11);
        path.moveTo(5, 10);
        path.lineTo(5, 20);
        path.lineTo(10, 20);
        path.lineTo(10, 14);
        path.lineTo(14, 14);
        path.lineTo(14, 20);
        path.lineTo(19, 20);
        path.lineTo(19, 10);
        break;
      case NavGlyph.map:
        path.moveTo(9, 4);
        path.lineTo(3, 6);
        path.lineTo(3, 20);
        path.lineTo(9, 18);
        path.lineTo(15, 20);
        path.lineTo(21, 18);
        path.lineTo(21, 4);
        path.lineTo(15, 6);
        path.close();
        path.moveTo(9, 4);
        path.lineTo(9, 18);
        path.moveTo(15, 6);
        path.lineTo(15, 20);
        break;
      case NavGlyph.volcano:
        path.moveTo(3, 20);
        path.lineTo(21, 20);
        path.lineTo(14, 9);
        path.lineTo(10, 9);
        path.close();
        path.moveTo(10, 9);
        path.lineTo(9, 6);
        path.moveTo(14, 9);
        path.lineTo(15, 6);
        path.moveTo(12, 8);
        path.lineTo(12, 4);
        break;
      case NavGlyph.book:
        path.moveTo(4, 5);
        path.quadraticBezierTo(4, 3, 6, 3);
        path.lineTo(19, 3);
        path.lineTo(19, 19);
        path.lineTo(6, 19);
        path.quadraticBezierTo(4, 19, 4, 21);
        path.close();
        path.moveTo(4, 19);
        path.quadraticBezierTo(4, 17, 6, 17);
        path.lineTo(19, 17);
        break;
      case NavGlyph.checklist:
        path.moveTo(4, 7);
        path.lineTo(6, 9);
        path.lineTo(9, 6);
        path.moveTo(4, 17);
        path.lineTo(6, 19);
        path.lineTo(9, 16);
        path.moveTo(13, 8);
        path.lineTo(20, 8);
        path.moveTo(13, 18);
        path.lineTo(20, 18);
        break;
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NavGlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
