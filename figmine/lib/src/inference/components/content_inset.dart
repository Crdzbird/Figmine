import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Measures how far the label of a component sits from its edge.
abstract final class ContentInset {
  /// The left auto layout padding between [node] and its first visible
  /// label, summed over nested layers such as a state wrapper around the
  /// button body. Null when no layer on the way uses auto layout.
  static double? horizontal(Map<String, Object?> node) {
    final (inset, auto) = _walk(node) ?? (0.0, false);
    return auto ? inset : null;
  }

  static (double, bool)? _walk(Map<String, Object?> node) {
    if (node['type'] == 'TEXT') return (0, false);
    for (final child in UsageStats.children(node)) {
      if (child['visible'] == false) continue;
      final inner = _walk(child);
      if (inner == null) continue;
      final layout = node['layoutMode'];
      final auto = layout == 'HORIZONTAL' || layout == 'VERTICAL';
      final own = node['paddingLeft'];
      final padding = auto && own is num ? own.toDouble() : 0.0;
      return (inner.$1 + padding, inner.$2 || auto);
    }
    return null;
  }
}
