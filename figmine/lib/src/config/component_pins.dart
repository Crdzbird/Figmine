import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/yaml_reader.dart';
import 'package:figmine/src/inference/metric_specs.dart';
import 'package:figmine/src/tokens/component_metric.dart';

/// Component dimensions set by hand in `figmine.yaml`.
abstract final class ComponentPins {
  /// Reads `components`, such as `inputHeight: 40`. Names must be figmine
  /// component metrics.
  static Map<String, double> fromYaml(YamlReader? yaml) {
    if (yaml == null) return const {};
    final pins = <String, double>{};
    for (final entry in yaml.map.entries) {
      final name = '${entry.key}';
      final value = double.tryParse('${entry.value}');
      if (!MetricSpecs.defaults.containsKey(name)) {
        throw ConfigException(
          '`components.$name` is not a component metric. Known metrics: '
          '${MetricSpecs.defaults.keys.join(', ')}.',
        );
      }
      if (value == null) {
        throw ConfigException('`components.$name` must be a number.');
      }
      pins[name] = value;
    }
    return pins;
  }

  /// [metrics] with [pins] in place of what the screens gave.
  static Map<String, ComponentMetric> apply(
    Map<String, ComponentMetric> metrics,
    Map<String, double> pins,
  ) => {
    ...metrics,
    for (final e in pins.entries)
      e.key: (value: e.value, doc: 'Set by hand in figmine.yaml, components.'),
  };
}
