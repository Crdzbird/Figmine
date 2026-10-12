import 'dart:math' as math;

/// Describes a state color as an overlay on a resting color, so that the
/// same relation can be applied in another mode.
abstract final class OverlayFit {
  static double _c(int argb, int shift) => (argb >> shift & 0xFF) / 255;

  /// [base] with [overlay] painted on top at [opacity], fully opaque.
  static int blend(int base, int overlay, double opacity) {
    int channel(int shift) {
      final b = _c(base, shift);
      final o = _c(overlay, shift);
      return ((b + (o - b) * opacity) * 255).round().clamp(0, 255);
    }

    return 0xFF000000 | channel(16) << 16 | channel(8) << 8 | channel(0);
  }

  /// The opacity of [overlay] on [base] that comes closest to [target],
  /// from 0 to 1, with the remaining error as a root mean square of the
  /// channels, also from 0 to 1.
  static (double, double) fit(int base, int overlay, int target) {
    var top = 0.0;
    var bottom = 0.0;
    for (final shift in const [16, 8, 0]) {
      final d = _c(overlay, shift) - _c(base, shift);
      top += d * (_c(target, shift) - _c(base, shift));
      bottom += d * d;
    }
    final opacity = bottom == 0 ? 0.0 : (top / bottom).clamp(0.0, 1.0);
    final mixed = blend(base, overlay, opacity);
    var error = 0.0;
    for (final shift in const [16, 8, 0]) {
      final d = _c(mixed, shift) - _c(target, shift);
      error += d * d;
    }
    return (opacity, math.sqrt(error / 3));
  }
}
