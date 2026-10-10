import 'dart:io';

import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/score/theme_snapshot.dart';
import 'package:figmine/src/sources/dtcg/dtcg_values.dart';
import 'package:yaml/yaml.dart';

/// Reads the expected values of a scorecard from YAML.
abstract final class ScoreReference {
  /// The reference at [path]: `colors` by role as `"#RRGGBB"` or
  /// `{light: ..., dark: ...}`, `components` as numbers, and `typography`
  /// roles as `{family: ..., size: ...}`. Every section is optional.
  static Future<ThemeSnapshot> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) throw ConfigException('No reference at $path.');
    final yaml = Json.map(loadYaml(await file.readAsString()));
    final colors = Json.map(yaml['colors']);
    int? hex(Object? value) =>
        value == null ? null : DtcgValues.color('$value')?.argb;
    Object? mode(Object? value, String name) =>
        value is Map ? value[name] : (name == 'light' ? value : null);
    return (
      light: {
        for (final e in colors.entries) e.key: ?hex(mode(e.value, 'light')),
      },
      dark: {
        for (final e in colors.entries) e.key: ?hex(mode(e.value, 'dark')),
      },
      components: {
        for (final e in Json.map(yaml['components']).entries)
          e.key: ?double.tryParse('${e.value}'),
      },
      text: {
        for (final e in Json.map(yaml['typography']).entries)
          if (Json.map(e.value) case final t)
            e.key: (
              family: '${t['family'] ?? ''}',
              size: double.tryParse('${t['size']}') ?? 0,
            ),
      },
    );
  }
}
