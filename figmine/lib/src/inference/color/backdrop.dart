import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/stats/node_facts.dart';

/// Tells the surfaces whose content is not drawn in the screen's mode.
abstract final class Backdrop {
  /// Whether [node] has an opaque dark fill, such as a dark mode screen.
  static bool dark(Map<String, Object?> node) {
    final fill = NodeFacts.fill(node);
    if (fill == null || ColorMath.alpha(fill) < 0.9) return false;
    return ColorMath.luminance(fill) < 0.2;
  }

  /// Whether [node] is a dark panel of at least 200 by 48 in a light
  /// screen, such as a snack bar, a tooltip or a dark example: the colors
  /// on it are inverse colors, not light mode ones. Smaller dark shapes,
  /// such as buttons, keep their labels in the light screen.
  static bool inverts(Map<String, Object?> node) {
    if (!dark(node)) return false;
    final size = NodeFacts.size(node);
    return size.width >= 200 && size.height >= 48;
  }
}
