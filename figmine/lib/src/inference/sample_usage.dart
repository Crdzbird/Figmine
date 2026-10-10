import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// What the samples of a component use most.
abstract final class SampleUsage {
  static final RegExp _size = RegExp(r'size\s*=\s*([a-z0-9-]+)');

  /// The size variant a sample names, such as `small` in `size=small`.
  static String? sizeOf(ComponentSample s) =>
      _size.firstMatch(s.name)?.group(1);

  /// The size variant most samples of [pool] name.
  static String? size(List<ComponentSample> pool) =>
      _top(pool.map(sizeOf).nonNulls);

  /// The component most instances of [pool] come from.
  static String? family(List<ComponentSample> pool) =>
      _top(pool.where((s) => s.instance).map((s) => s.family));

  static String? _top(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      UsageStats.count(counts, value);
    }
    final ranked = counts.keys.toList()
      ..sort((a, b) => counts[b]! - counts[a]!);
    return ranked.firstOrNull;
  }
}
