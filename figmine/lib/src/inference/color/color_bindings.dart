import 'package:figmine/src/inference/stats/paint_usage.dart';

/// Counts which Figma variables each color is bound to, per usage.
final class ColorBindings {
  /// Creates empty counts.
  factory() = ColorBindings._;

  new _();

  final Map<String, Map<String, int>> _counts = {};

  /// Records that a layer painted [argb] as [usage] through variable [id].
  void add(PaintUsage usage, int argb, String? id) {
    if (id == null) return;
    final counts = _counts.putIfAbsent('${usage.name}|$argb', () => {});
    counts[id] = (counts[id] ?? 0) + 1;
  }

  /// The variable most often bound to [argb] as [usage], falling back to
  /// any usage of the color.
  String? mostCommon(PaintUsage usage, int argb) {
    final counts =
        _counts['${usage.name}|$argb'] ??
        _counts.entries
            .where((e) => e.key.endsWith('|$argb'))
            .map((e) => e.value)
            .firstOrNull;
    if (counts == null || counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
