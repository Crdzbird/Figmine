import 'package:figmine/src/inference/component_body.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/content_inset.dart';
import 'package:figmine/src/inference/node_facts.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Measures component instances, and spots buttons drawn without components.
abstract final class SampleReader {
  /// Reads the measurements of [node] as a [kind].
  ///
  /// [name] holds the component set and variant names, when known.
  /// [instance] tells a component instance from a lookalike layer, and
  /// [family] names its component set.
  static ComponentSample read(
    Map<String, Object?> node,
    ComponentKind kind, {
    String name = '',
    bool instance = false,
    String family = '',
  }) {
    final painted =
        NodeFacts.fill(node) != null || NodeFacts.stroke(node) != null;
    final background = painted ? node : ComponentBody.of(node);
    final label = NodeFacts.find(node, (n) => n['type'] == 'TEXT');
    final shape = background ?? node;
    final mark = ComponentBody.mark(shape);
    final top = node['paddingTop'];
    return (
      kind: kind,
      name: name.toLowerCase(),
      instance: instance,
      family: family.toLowerCase(),
      fill: background == null ? null : NodeFacts.fill(background),
      fillVariable: background == null
          ? null
          : NodeFacts.paintVariable(background, 'fills'),
      stroke: NodeFacts.stroke(shape) ?? NodeFacts.stroke(node),
      strokeVariable:
          NodeFacts.paintVariable(shape, 'strokes') ??
          NodeFacts.paintVariable(node, 'strokes'),
      label: label == null ? null : NodeFacts.fill(label),
      labelVariable: label == null
          ? null
          : NodeFacts.paintVariable(label, 'fills'),
      radius: NodeFacts.radius(shape),
      pill: NodeFacts.isPill(shape),
      height: NodeFacts.size(background ?? node).height,
      paddingHorizontal: ContentInset.horizontal(node),
      padding: top is num ? top.toDouble() : null,
      shadow: NodeFacts.shadow(shape),
      mark: mark == null
          ? null
          : NodeFacts.fill(mark) ?? NodeFacts.stroke(mark),
      markVariable: mark == null
          ? null
          : NodeFacts.paintVariable(mark, 'fills') ??
                NodeFacts.paintVariable(mark, 'strokes'),
    );
  }

  /// Whether [node] looks like a button built without a component: an auto
  /// layout with a short label, a fill, rounded corners and button height.
  static bool looksLikeButton(Map<String, Object?> node) {
    final type = node['type'];
    if (type != 'FRAME' && type != 'INSTANCE') return false;
    final layout = node['layoutMode'];
    if (layout != 'HORIZONTAL' && layout != 'VERTICAL') return false;
    final children = UsageStats.children(node).toList();
    if (children.isEmpty || children.length > 3) return false;
    final hasLabel = children.any((c) => c['type'] == 'TEXT');
    final size = NodeFacts.size(node);
    return hasLabel &&
        NodeFacts.fill(node) != null &&
        NodeFacts.radius(node) != null &&
        size.height >= 28 &&
        size.height <= 64 &&
        size.width <= 360;
  }
}
