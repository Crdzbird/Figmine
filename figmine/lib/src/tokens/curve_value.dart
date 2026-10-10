/// An easing curve token, as the control points of a cubic bezier.
final class CurveValue {
  /// Creates a curve through ([x1], [y1]) and ([x2], [y2]).
  const factory(double x1, double y1, double x2, double y2) = CurveValue._;

  const new _(this.x1, this.y1, this.x2, this.y2);

  /// The x of the first control point.
  final double x1;

  /// The y of the first control point.
  final double y1;

  /// The x of the second control point.
  final double x2;

  /// The y of the second control point.
  final double y2;

  static final RegExp _css = RegExp(r'^\s*cubic-bezier\(([^)]*)\)\s*$');

  /// Parses `cubic-bezier(0.2, 0, 0, 1)` or a list of four numbers, or
  /// returns null.
  static CurveValue? tryParse(Object? raw) {
    if (raw is CurveValue) return raw;
    final parts = switch (raw) {
      final List<Object?> list => [for (final n in list) _number(n)],
      final String text => [
        for (final n in (_css.firstMatch(text)?.group(1) ?? '').split(','))
          double.tryParse(n.trim()),
      ],
      _ => const <num?>[],
    };
    if (parts.length != 4 || parts.contains(null)) return null;
    final [x1, y1, x2, y2] = [for (final n in parts) n!.toDouble()];
    return CurveValue(x1, y1, x2, y2);
  }

  static num? _number(Object? n) => n is num ? n : null;

  @override
  String toString() => 'cubic-bezier($x1, $y1, $x2, $y2)';
}
