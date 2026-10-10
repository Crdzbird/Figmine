import 'package:flutter/widgets.dart';

/// Draws an easing [curve] from the bottom left to the top right.
final class FigmineCurvePainter extends CustomPainter {
  /// Creates a painter of [curve] in [color].
  const factory(Curve curve, Color color) = FigmineCurvePainter._;

  const new _(this.curve, this.color);

  /// The curve drawn.
  final Curve curve;

  /// The line color.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height);
    for (var i = 1; i <= 40; i++) {
      final t = i / 40;
      path.lineTo(t * size.width, size.height * (1 - curve.transform(t)));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(FigmineCurvePainter oldDelegate) =>
      oldDelegate.curve != curve || oldDelegate.color != color;
}
