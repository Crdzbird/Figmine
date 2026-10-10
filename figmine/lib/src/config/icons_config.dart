import 'package:figmine/src/config/yaml_reader.dart';

/// The `icons` section of `figmine.yaml`.
final class IconsConfig {
  /// Creates icon settings.
  const factory({
    required List<String> nodeIds,
    String namePrefix,
    String output,
  }) = IconsConfig._;

  const new _({
    required this.nodeIds,
    this.namePrefix = '',
    this.output = 'assets/figmine/icons',
  });

  /// Reads the section from YAML. Returns null when no node is configured.
  static IconsConfig? fromYaml(YamlReader? yaml) {
    if (yaml == null) return null;
    final ids = yaml.strings('node_ids');
    if (ids.isEmpty) return null;
    return IconsConfig(
      nodeIds: [for (final id in ids) id.replaceAll('-', ':')],
      namePrefix: yaml.string('name_prefix') ?? '',
      output: yaml.string('output') ?? 'assets/figmine/icons',
    );
  }

  /// Pages, frames or sections that contain the icon components.
  final List<String> nodeIds;

  /// Only components whose name starts with this prefix are exported.
  final String namePrefix;

  /// Directory, relative to the project, that receives the SVG files.
  final String output;
}
