import 'package:figmine/src/tokens/color_value.dart';

/// One shadow of an effect style.
typedef ShadowLayer = ({
  ColorValue color,
  double x,
  double y,
  double blur,
  double spread,
  bool inner,
});

/// The shadows of a Figma effect style, drawn in order.
final class ShadowValue {
  /// Creates a value of [layers].
  const factory(List<ShadowLayer> layers) = ShadowValue._;

  const new _(this.layers);

  /// The shadows, bottom first.
  final List<ShadowLayer> layers;
}
