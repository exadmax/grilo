import 'package:flutter/material.dart';

/// Brand "cube" mark — wireframe box, used for the sidebar logo and the
/// client-quote brand mark.
class GriloCubeIcon extends StatelessWidget {
  const GriloCubeIcon({super.key, this.size = 20, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CubePainter(color ?? IconTheme.of(context).color ?? Colors.white),
    );
  }
}

class _CubePainter extends CustomPainter {
  _CubePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final hex = Path()
      ..moveTo(12 * s, 2.5 * s)
      ..lineTo(21 * s, 7 * s)
      ..lineTo(21 * s, 17 * s)
      ..lineTo(12 * s, 21.5 * s)
      ..lineTo(3 * s, 17 * s)
      ..close();
    final innerV = Path()
      ..moveTo(3 * s, 7 * s)
      ..lineTo(12 * s, 11.5 * s)
      ..lineTo(21 * s, 7 * s);
    final vert = Path()
      ..moveTo(12 * s, 11.5 * s)
      ..lineTo(12 * s, 21.5 * s);

    canvas.drawPath(hex, paint);
    canvas.drawPath(innerV, paint);
    canvas.drawPath(vert, paint);
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) => oldDelegate.color != color;
}

/// "Yarn ball" icon used for the Crochê engine selector.
class GriloYarnIcon extends StatelessWidget {
  const GriloYarnIcon({super.key, this.size = 20, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _YarnPainter(color ?? IconTheme.of(context).color ?? Colors.white),
    );
  }
}

class _YarnPainter extends CustomPainter {
  _YarnPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(11 * s, 12 * s), 7.5 * s, paint);

    final strands = Path()
      ..moveTo(5.5 * s, 8.5 * s)
      ..relativeCubicTo(3 * s, 1.5 * s, 7.5 * s, 4 * s, 9.5 * s, 8 * s)
      ..moveTo(7 * s, 5.5 * s)
      ..relativeCubicTo(3.5 * s, 2 * s, 8 * s, 5.5 * s, 9.5 * s, 9.5 * s)
      ..moveTo(17 * s, 7 * s)
      ..relativeCubicTo(1.5 * s, 2 * s, 2 * s, 4 * s, 1 * s, 6.5 * s);
    canvas.drawPath(strands, paint);
  }

  @override
  bool shouldRepaint(covariant _YarnPainter oldDelegate) => oldDelegate.color != color;
}
