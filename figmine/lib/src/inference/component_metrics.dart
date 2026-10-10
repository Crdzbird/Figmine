import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/metric_reads.dart';
import 'package:figmine/src/inference/metric_specs.dart';
import 'package:figmine/src/tokens/component_metric.dart';

/// Measures component dimensions from samples, with Material defaults.
abstract final class ComponentMetrics {
  /// Every metric, measured where samples exist.
  static Map<String, ComponentMetric> infer(List<ComponentSample> samples) => {
    for (final MapEntry(key: name, value: (kind, read, median))
        in MetricReads.all.entries)
      name: _metric(name, kind, read, samples, median: median),
  };

  static ComponentMetric _metric(
    String name,
    ComponentKind kind,
    double? Function(ComponentSample sample) read,
    List<ComponentSample> samples, {
    required bool median,
  }) {
    final (min, max) = MetricSpecs.ranges[name] ?? (0, 999);
    bool fits(double? v) => v != null && v.round() >= min && v.round() <= max;
    final picked = ComponentSamples.select(
      kind,
      samples,
      measured: (s) => fits(read(s)),
    );
    final values = picked.samples
        .map(read)
        .whereType<double>()
        .map((v) => v.roundToDouble())
        .toList();
    final plausible = values.where(fits).toList();
    if (plausible.isEmpty) {
      final why = values.isEmpty
          ? 'no ${kind.name} found in the screens'
          : '${values.length} ${kind.name} values outside '
                '${min.round()} to ${max.round()}';
      final value = MetricSpecs.defaults[name]!;
      return (value: value, doc: 'Material default: $why.');
    }
    final what = picked.label;
    if (median) {
      final sorted = plausible..sort();
      final value = sorted[sorted.length ~/ 2];
      return (value: value, doc: 'Median of ${sorted.length} $what.');
    }
    return (
      value: _mode(plausible),
      doc: 'Most common across ${plausible.length} $what.',
    );
  }

  static double _mode(List<double> values) {
    final counts = <double, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
