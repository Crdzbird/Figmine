import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Carries layer opacity down a component, as Figma multiplies it.
abstract final class NodeOpacity {
  /// A copy of [node] where every layer's `opacity` is its own times its
  /// parents', so a fill under a 38% group reads as it looks.
  static Map<String, Object?> flatten(
    Map<String, Object?> node, [
    double inherited = 1,
  ]) {
    final own = node['opacity'];
    final opacity = inherited * (own is num ? own.toDouble() : 1);
    if (opacity == 1 && !_faded(node)) return node;
    return {
      ...node,
      'opacity': opacity,
      'children': [
        for (final child in UsageStats.children(node)) flatten(child, opacity),
      ],
    };
  }

  static bool _faded(Map<String, Object?> node) => UsageStats.children(
    node,
  ).any((c) => c['opacity'] is num && (c['opacity']! as num) < 1 || _faded(c));
}
