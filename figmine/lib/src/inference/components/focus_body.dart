import 'package:figmine/src/inference/components/component_body.dart';
import 'package:figmine/src/inference/stats/node_facts.dart';

/// Finds the layer that fills a component.
abstract final class FocusBody {
  /// The layer whose fill is the component's: [background] itself when it
  /// has a fill, or, for an outline with no fill such as a focus ring, the
  /// solid layer inside that covers at least half of [node].
  static Map<String, Object?> of(
    Map<String, Object?> node,
    Map<String, Object?>? background,
  ) {
    if (background == null) return const {};
    if (NodeFacts.fill(background) != null) return background;
    final inner = ComponentBody.of(background, opaque: true);
    if (inner == null) return background;
    final outer = NodeFacts.size(node);
    final size = NodeFacts.size(inner);
    final covers = size.width * size.height >= outer.width * outer.height / 2;
    return covers ? inner : background;
  }
}
