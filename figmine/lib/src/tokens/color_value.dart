/// An RGBA color read from Figma, with channels in the 0 to 1 range.
final class ColorValue {
  /// Creates a color from normalized channels.
  const factory({
    required double r,
    required double g,
    required double b,
    double a,
  }) = ColorValue._;

  const new _({required this.r, required this.g, required this.b, this.a = 1});

  /// Creates a color from a 32 bit ARGB integer.
  factory fromArgb(int argb) => ColorValue(
    r: (argb >> 16 & 0xFF) / 255,
    g: (argb >> 8 & 0xFF) / 255,
    b: (argb & 0xFF) / 255,
    a: (argb >> 24 & 0xFF) / 255,
  );

  /// Reads a Figma color object such as `{"r": 1, "g": 0, "b": 0, "a": 1}`.
  ///
  /// Returns null when [json] is not a color.
  static ColorValue? tryParse(Object? json, {double opacity = 1}) {
    if (json is! Map) return null;
    final r = json['r'];
    final g = json['g'];
    final b = json['b'];
    if (r is! num || g is! num || b is! num) return null;
    final a = json['a'];
    return ColorValue(
      r: r.toDouble(),
      g: g.toDouble(),
      b: b.toDouble(),
      a: (a is num ? a.toDouble() : 1) * opacity,
    );
  }

  /// Red channel.
  final double r;

  /// Green channel.
  final double g;

  /// Blue channel.
  final double b;

  /// Alpha channel.
  final double a;

  /// The color packed as a 32 bit ARGB integer.
  int get argb =>
      _channel(a) << 24 | _channel(r) << 16 | _channel(g) << 8 | _channel(b);

  /// The color as a Dart hex literal such as `0xFF112233`.
  String get hex => '0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static int _channel(double value) => (value.clamp(0, 1) * 255).round();
}
