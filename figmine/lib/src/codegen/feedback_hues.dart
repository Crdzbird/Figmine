import 'package:figmine/src/inference/color_math.dart';

/// The hues each feedback role can plausibly have.
abstract final class FeedbackHues {
  static const Map<String, (double, double)> _bands = {
    'error': (330, 30),
    'success': (80, 170),
    'warning': (15, 70),
    'info': (170, 270),
  };

  /// Whether [argb] has a hue that fits the role [name], such as a green
  /// for `success`. Grays fit no role; roles without a band fit anything.
  static bool fits(String name, int argb) {
    final band = _bands[name];
    if (band == null) return true;
    if (ColorMath.chroma(argb) < 0.1) return false;
    final hue = ColorMath.hue(argb);
    final (low, high) = band;
    return low <= high ? hue >= low && hue <= high : hue >= low || hue <= high;
  }
}
