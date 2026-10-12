import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/stats/layout_recorder.dart';
import 'package:figmine/src/inference/stats/node_facts.dart';
import 'package:figmine/src/inference/stats/paint_usage.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Records the paints, text, layout and corners of one layer.
abstract final class PaintRecorder {
  /// Adds [node] to [stats]. Returns true for text layers, whose children
  /// need no walk.
  static bool add(UsageStats stats, Map<String, Object?> node) {
    final fill = NodeFacts.fill(node);
    final opaque = fill != null && ColorMath.alpha(fill) >= 0.9;
    if (node['type'] == 'TEXT') {
      final chars = '${node['characters'] ?? ''}'.length;
      if (opaque) {
        UsageStats.count(stats.textCharacters, fill, chars);
        (stats.colorFrames[fill] ??= {}).add(stats.frames);
        stats.bindings.add(PaintUsage.text, fill, _bound(node, 'fills'));
      }
      stats.addText(Json.map(node['style']), chars);
      return true;
    }
    final size = NodeFacts.size(node);
    if (opaque) {
      final area = size.width * size.height;
      stats.backgroundArea[fill] = (stats.backgroundArea[fill] ?? 0) + area;
      stats.totalArea += area;
      UsageStats.count(stats.backgroundLayers, fill);
      (stats.colorFrames[fill] ??= {}).add(stats.frames);
      stats.bindings.add(PaintUsage.background, fill, _bound(node, 'fills'));
    }
    final stroke = NodeFacts.stroke(node);
    final glyph = _glyphs.contains(node['type']);
    if (stroke != null && !glyph && ColorMath.alpha(stroke) >= 0.5) {
      UsageStats.count(stats.strokes, stroke);
      stats.bindings.add(PaintUsage.stroke, stroke, _bound(node, 'strokes'));
    }
    LayoutRecorder.add(stats, node);
    final radius = NodeFacts.radius(node);
    if (radius != null && node['type'] != 'ELLIPSE') {
      final pill = NodeFacts.isPill(node);
      if (pill) stats.pills++;
      if (!pill) UsageStats.count(stats.radii, radius.round());
    }
    return false;
  }

  /// Shapes that draw icons, whose strokes are not borders.
  static const Set<String> _glyphs = {
    'VECTOR',
    'BOOLEAN_OPERATION',
    'STAR',
    'POLYGON',
    'REGULAR_POLYGON',
  };

  static String? _bound(Map<String, Object?> node, String property) =>
      NodeFacts.paintVariable(node, property);
}
