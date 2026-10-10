/// A font weight token, from 1 to 1000.
final class FontWeightValue {
  /// Creates a font weight of [weight].
  const factory(int weight) = FontWeightValue._;

  const new _(this.weight);

  /// The weight, such as 400 for regular and 700 for bold.
  final int weight;

  /// The weight [raw] holds, when it is a whole number from 1 to 1000.
  static FontWeightValue? tryParse(Object? raw) {
    if (raw is FontWeightValue) return raw;
    if (raw is! num || raw != raw.roundToDouble()) return null;
    if (raw < 1 || raw > 1000) return null;
    return FontWeightValue(raw.round());
  }

  @override
  String toString() => 'w$weight';
}
