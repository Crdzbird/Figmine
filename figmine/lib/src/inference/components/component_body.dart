import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/stats/node_facts.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Finds the painted parts of a component.
abstract final class ComponentBody {
  /// The largest painted layer inside [node], such as the field box of an
  /// input under its label, or null when nothing is painted. With
  /// [opaque], only solid fills count, skipping a scrim.
  static Map<String, Object?>? of(
    Map<String, Object?> node, {
    bool opaque = false,
  }) {
    Map<String, Object?>? best;
    var area = 0.0;
    void walk(Map<String, Object?> n) {
      for (final child in UsageStats.children(n)) {
        if (child['visible'] == false || child['type'] == 'TEXT') continue;
        final size = NodeFacts.size(child);
        final fill = NodeFacts.fill(child);
        final solid = fill != null && ColorMath.alpha(fill) >= 0.9;
        final painted = opaque
            ? solid
            : fill != null || NodeFacts.stroke(child) != null;
        if (painted && size.width * size.height > area) {
          best = child;
          area = size.width * size.height;
        }
        walk(child);
      }
    }

    walk(node);
    return best;
  }

  /// The first painted layer inside [shape], other than text, such as the
  /// check of a checkbox, the dot of a radio or the thumb of a switch.
  static Map<String, Object?>? mark(Map<String, Object?> shape) =>
      NodeFacts.find(
        shape,
        (n) =>
            n['type'] != 'TEXT' &&
            (NodeFacts.fill(n) != null || NodeFacts.stroke(n) != null),
      );
}
