import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/component_sample.dart';

/// Tells filled buttons from outlined ones.
abstract final class ButtonStyleKind {
  /// Whether [s] is a labelled, filled button.
  static bool isFilled(ComponentSample s) => s.label != null && s.fill != null;

  /// Whether [s] is a labelled button with neither a border nor a fill
  /// that stands out from the surface.
  static bool isText(ComponentSample s) {
    final fill = s.fill;
    if (s.label == null || s.stroke != null) return false;
    return fill == null || ColorMath.contrast(fill, ColorMath.white) < 1.1;
  }

  /// Whether [s] is a labelled button with a visible border that differs
  /// from its fill, and no fill or a light one, close to the surface.
  static bool isOutlined(ComponentSample s) {
    final stroke = s.stroke;
    final fill = s.fill;
    if (s.label == null || stroke == null || stroke == fill) return false;
    return fill == null || ColorMath.contrast(fill, ColorMath.white) < 2;
  }
}
