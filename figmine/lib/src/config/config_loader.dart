import 'dart:io';

import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/file_key.dart';
import 'package:yaml/yaml.dart';

/// Reads `figmine.yaml` from disk.
abstract final class ConfigLoader {
  /// Loads the configuration file at [path].
  ///
  /// A [layout] overrides `output.layout`.
  static Future<FigmineConfig> load(String path, {String? layout}) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw ConfigException('$path not found. Run `dart run figmine init`.');
    }
    final root = loadYaml(await file.readAsString());
    if (root is! Map) throw ConfigException('$path must be a YAML map.');
    final config = FigmineConfig.fromYaml(
      layout == null
          ? root
          : {
              ...root,
              'output': {...?root['output'] as Map?, 'layout': layout},
            },
    );
    final problem = FileKey.problem(config.fileKey);
    if (problem != null) throw ConfigException(problem);
    return config;
  }
}
