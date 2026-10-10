import 'package:figmine/src/inference/node_facts.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Finds the painted parts of a component.
abstract final class ComponentBody {
  /// The largest painted layer inside [node], such as the field box of an
  /// input under its label, or null when nothing is painted.
  static Map<String, Object?>? of(Map<String, Object?> node) {
    Map<String, Object?>? best;
    var area = 0.0;
    void walk(Map<String, Object?> n) {
      for (final child in UsageStats.children(n)) {
        if (child['visible'] == false || child['type'] == 'TEXT') continue;
        final size = NodeFacts.size(child);
        final painted =
            NodeFacts.fill(child) != null || NodeFacts.stroke(child) != null;
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
