import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// Reads visual facts from Figma nodes.
abstract final class NodeFacts {
  /// The first visible solid fill as ARGB, with layer opacity applied.
  static int? fill(Map<String, Object?> node) => _solid(node['fills'], node);

  /// The first visible solid stroke as ARGB, when strokes have a weight.
  static int? stroke(Map<String, Object?> node) {
    final weight = node['strokeWeight'];
    if (weight is! num || weight <= 0) return null;
    return _solid(node['strokes'], node);
  }

  /// Id of the variable bound to the first visible solid paint of
  /// [property], `fills` or `strokes`, if any.
  static String? paintVariable(Map<String, Object?> node, String property) {
    for (final paint in Json.list(node[property]).map(Json.map)) {
      if (paint['type'] != 'SOLID' || paint['visible'] == false) continue;
      final bound = Json.map(Json.map(paint['boundVariables'])['color']);
      final layer = Json.list(Json.map(node['boundVariables'])[property]);
      final id = bound['id'] ?? Json.map(layer.firstOrNull)['id'];
      return id is String ? id : null;
    }
    return null;
  }

  /// Width and height of the node.
  static ({double width, double height}) size(Map<String, Object?> node) {
    final box = Json.map(node['absoluteBoundingBox']);
    final w = box['width'];
    final h = box['height'];
    return (
      width: w is num ? w.toDouble() : 0,
      height: h is num ? h.toDouble() : 0,
    );
  }

  /// Corner radius, the largest corner when they differ, or null.
  static double? radius(Map<String, Object?> node) {
    final radius = node['cornerRadius'];
    if (radius is num && radius > 0) return radius.toDouble();
    final corners = Json.list(node['rectangleCornerRadii']).whereType<num>();
    if (corners.isEmpty) return null;
    final max = corners.reduce((a, b) => a > b ? a : b).toDouble();
    return max > 0 ? max : null;
  }

  /// Whether the node is a fully rounded pill.
  static bool isPill(Map<String, Object?> node) {
    final r = radius(node);
    final s = size(node);
    final shortest = s.width < s.height ? s.width : s.height;
    return r != null && shortest > 0 && r >= shortest / 2 - 0.5;
  }

  /// The first descendant, depth first, that satisfies [test].
  static Map<String, Object?>? find(
    Map<String, Object?> node,
    bool Function(Map<String, Object?> node) test,
  ) {
    for (final child in Json.list(node['children']).map(Json.map)) {
      if (child['visible'] == false) continue;
      if (test(child)) return child;
      final nested = find(child, test);
      if (nested != null) return nested;
    }
    return null;
  }

  /// Blur radius of the first visible drop shadow.
  static double shadow(Map<String, Object?> node) {
    for (final effect in Json.list(node['effects']).map(Json.map)) {
      final visible = effect['visible'] != false;
      if (effect['type'] != 'DROP_SHADOW' || !visible) continue;
      final radius = effect['radius'];
      return radius is num ? radius.toDouble() : 0;
    }
    return 0;
  }

  static int? _solid(Object? paints, Map<String, Object?> node) {
    final layer = node['opacity'];
    for (final paint in Json.list(paints).map(Json.map)) {
      if (paint['type'] != 'SOLID' || paint['visible'] == false) continue;
      final opacity = paint['opacity'];
      return ColorValue.tryParse(
        paint['color'],
        opacity:
            (opacity is num ? opacity.toDouble() : 1) *
            (layer is num ? layer.toDouble() : 1),
      )?.argb;
    }
    return null;
  }
}
