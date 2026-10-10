/// A duration token, such as a motion timing.
final class DurationValue {
  /// Creates a duration of [milliseconds].
  const factory(double milliseconds) = DurationValue._;

  const new _(this.milliseconds);

  /// The length in milliseconds.
  final double milliseconds;

  /// Parses `200ms`, `0.2s`, a number of milliseconds or a DTCG
  /// `{value, unit}` object, or returns null.
  static DurationValue? tryParse(Object? raw) {
    if (raw is DurationValue) return raw;
    if (raw is num) return DurationValue(raw.toDouble());
    if (raw is Map) {
      final value = raw['value'];
      if (value is! num) return null;
      return DurationValue(value * (raw['unit'] == 's' ? 1000 : 1));
    }
    if (raw is! String) return null;
    final match = RegExp(r'^\s*(-?[\d.]+)\s*(ms|s)?\s*$').firstMatch(raw);
    final value = double.tryParse(match?.group(1) ?? '');
    if (value == null) return null;
    return DurationValue(value * (match!.group(2) == 's' ? 1000 : 1));
  }

  @override
  String toString() {
    final whole = milliseconds == milliseconds.roundToDouble();
    return '${whole ? milliseconds.round() : milliseconds}ms';
  }
}
