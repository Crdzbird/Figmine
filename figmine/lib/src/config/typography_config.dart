import 'package:figmine/src/config/yaml_reader.dart';

/// The `typography` section of `figmine.yaml`.
final class TypographyConfig {
  /// Creates typography settings.
  const factory({bool enabled, String stripPrefix, Map<String, String> roles}) =
      TypographyConfig._;

  const new _({
    this.enabled = true,
    this.stripPrefix = '',
    this.roles = const {},
  });

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) => TypographyConfig(
    enabled: yaml.boolean('enabled') ?? true,
    stripPrefix: yaml.string('strip_prefix') ?? '',
    roles: yaml.stringMap('roles'),
  );

  /// Whether text styles are read from Figma.
  final bool enabled;

  /// Prefix removed from text style names.
  final String stripPrefix;

  /// Explicit TextTheme role to text style name mapping.
  final Map<String, String> roles;

  /// Splits [name] into segments and removes [stripPrefix].
  List<String> pathOf(String name) {
    final trimmed = name.startsWith(stripPrefix)
        ? name.substring(stripPrefix.length)
        : name;
    return [
      for (final segment in trimmed.split('/'))
        if (segment.trim().isNotEmpty) segment.trim(),
    ];
  }
}
