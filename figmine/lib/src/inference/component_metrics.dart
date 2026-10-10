import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/metric_specs.dart';
import 'package:figmine/src/tokens/component_metric.dart';

/// Measures component dimensions from samples, with Material defaults.
abstract final class ComponentMetrics {
  /// Every metric, measured where samples exist.
  static Map<String, ComponentMetric> infer(List<ComponentSample> samples) {
    double? radius(ComponentSample s) => s.pill ? 999 : s.radius;
    double? elevation(ComponentSample s) =>
        s.shadow > 0 ? (s.shadow / 2).clamp(1, 12).roundToDouble() : 0;
    ComponentMetric metric(
      String name,
      ComponentKind kind,
      double? Function(ComponentSample sample) read, {
      bool median = false,
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

    return {
      'buttonRadius': metric('buttonRadius', ComponentKind.button, radius),
      'buttonHeight': metric(
        'buttonHeight',
        ComponentKind.button,
        (s) => s.height > 0 ? s.height : null,
        median: true,
      ),
      'buttonPaddingHorizontal': metric(
        'buttonPaddingHorizontal',
        ComponentKind.button,
        (s) => s.paddingHorizontal,
        median: true,
      ),
      'cardRadius': metric('cardRadius', ComponentKind.card, radius),
      'cardPadding': metric(
        'cardPadding',
        ComponentKind.card,
        (s) => s.padding,
      ),
      'cardElevation': metric('cardElevation', ComponentKind.card, elevation),
      'inputRadius': metric('inputRadius', ComponentKind.input, radius),
      'inputHeight': metric(
        'inputHeight',
        ComponentKind.input,
        (s) => s.height > 0 ? s.height : null,
      ),
      'chipRadius': metric('chipRadius', ComponentKind.chip, radius),
      'appBarHeight': metric(
        'appBarHeight',
        ComponentKind.appBar,
        (s) => s.height > 0 ? s.height : null,
      ),
    };
  }

  static double _mode(List<double> values) {
    final counts = <double, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
