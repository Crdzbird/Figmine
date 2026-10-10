import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/yaml_reader.dart';
import 'package:figmine/src/sources/dtcg/dtcg_values.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// A color set by hand for the light and dark scheme. Without a dark value
/// the dark scheme derives one.
typedef ColorOverride = ({ColorValue light, ColorValue? dark});

/// Reads `color_scheme.overrides`.
abstract final class ColorOverrides {
  /// Parses `role: "#RRGGBB"` or `role: {light: "#..", dark: "#.."}`.
  static Map<String, ColorOverride> fromYaml(YamlReader yaml) {
    final raw = yaml.map['overrides'];
    if (raw == null) return const {};
    if (raw is! Map) {
      throw const ConfigException('`color_scheme.overrides` must be a map.');
    }
    return {
      for (final entry in raw.entries)
        '${entry.key}': _parse('${entry.key}', entry.value),
    };
  }

  static ColorOverride _parse(String role, Object? value) {
    final light = value is Map ? value['light'] : value;
    final dark = value is Map ? value['dark'] : null;
    final l = DtcgValues.color('${light ?? ''}');
    final d = dark == null ? null : DtcgValues.color('$dark');
    if (l == null || (dark != null && d == null)) {
      throw ConfigException(
        '`color_scheme.overrides.$role` must be a hex color such as "#1B115C" '
        'or {light: "#...", dark: "#..."}.',
      );
    }
    return (light: l, dark: d);
  }
}
