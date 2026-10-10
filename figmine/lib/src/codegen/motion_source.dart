import 'package:figmine/src/tokens/curve_value.dart';
import 'package:figmine/src/tokens/duration_value.dart';
import 'package:figmine/src/tokens/font_weight_value.dart';

/// Renders durations, curves and font weights as Dart constants.
abstract final class MotionSource {
  /// A `Duration` literal, in microseconds when milliseconds are partial.
  static String duration(DurationValue value) {
    final ms = value.milliseconds;
    final whole = ms == ms.roundToDouble();
    return whole
        ? 'Duration(milliseconds: ${ms.round()})'
        : 'Duration(microseconds: ${(ms * 1000).round()})';
  }

  /// A `Cubic` literal.
  static String curve(CurveValue value) =>
      'Cubic(${[value.x1, value.y1, value.x2, value.y2].map(_n).join(', ')})';

  /// A named `FontWeight` such as `FontWeight.w600`, or `FontWeight(n)`.
  static String weight(FontWeightValue value) {
    final w = value.weight;
    if (w % 100 == 0 && w >= 100 && w <= 900) return 'FontWeight.w$w';
    return 'FontWeight($w)';
  }

  static String _n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';
}
