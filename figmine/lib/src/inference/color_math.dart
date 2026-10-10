import 'dart:math' as math;

/// Color measurements used to recognize roles.
abstract final class ColorMath {
  /// White.
  static const int white = 0xFFFFFFFF;

  /// Black.
  static const int black = 0xFF000000;

  static double _channel(int argb, int shift) => (argb >> shift & 0xFF) / 255;

  /// Alpha from 0 to 1.
  static double alpha(int argb) => _channel(argb, 24);

  /// WCAG relative luminance.
  static double luminance(int argb) {
    double linear(double c) => c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * linear(_channel(argb, 16)) +
        0.7152 * linear(_channel(argb, 8)) +
        0.0722 * linear(_channel(argb, 0));
  }

  /// WCAG contrast ratio between [a] and [b], from 1 to 21.
  static double contrast(int a, int b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Colorfulness from 0 for grays to 1 for pure hues.
  static double chroma(int argb) {
    final channels = [16, 8, 0].map((s) => _channel(argb, s));
    return channels.reduce(math.max) - channels.reduce(math.min);
  }

  /// Hue angle from 0 to 360.
  static double hue(int argb) {
    final r = _channel(argb, 16);
    final g = _channel(argb, 8);
    final b = _channel(argb, 0);
    final max = math.max(r, math.max(g, b));
    final delta = max - math.min(r, math.min(g, b));
    if (delta == 0) return 0;
    final sector = max == r
        ? ((g - b) / delta) % 6
        : (max == g ? (b - r) / delta + 2 : (r - g) / delta + 4);
    return sector * 60 % 360;
  }

  /// Smallest angle between the hues of [a] and [b].
  static double hueDistance(int a, int b) {
    final d = (hue(a) - hue(b)).abs();
    return math.min(d, 360 - d);
  }

  /// Whether [a] and [b] read as different colors: hues apart, such as
  /// sky blue and royal blue, or the same hue at clearly different
  /// lightness, such as navy and blue.
  static bool distinct(int a, int b) =>
      hueDistance(a, b) >= 20 || contrast(a, b) >= 3;

  /// White or black, whichever contrasts more with [background].
  static int readableOn(int background) =>
      contrast(white, background) >= contrast(black, background)
      ? white
      : black;

  /// The color as `#RRGGBB`, with alpha when not opaque.
  static String hex(int argb) {
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final a = argb >> 24 & 0xFF;
    if (a == 0xFF) return '#${rgb.toUpperCase()}';
    final alpha = a.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#${rgb.toUpperCase()}$alpha';
  }
}
