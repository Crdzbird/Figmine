import 'package:figmine/src/inference/usage_stats.dart';

/// Records auto layout paddings and gaps.
abstract final class LayoutRecorder {
  /// Adds the auto layout paddings and gap of [node] to [stats].
  static void add(UsageStats stats, Map<String, Object?> node) {
    final mode = node['layoutMode'];
    if (mode != 'HORIZONTAL' && mode != 'VERTICAL') return;
    for (final key in const [
      'paddingLeft',
      'paddingRight',
      'paddingTop',
      'paddingBottom',
      'itemSpacing',
    ]) {
      final value = node[key];
      if (value is! num || value <= 0 || value > 128) continue;
      UsageStats.count(stats.spacing, value.round());
    }
  }
}
