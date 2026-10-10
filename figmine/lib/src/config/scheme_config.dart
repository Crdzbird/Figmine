import 'package:figmine/src/config/color_overrides.dart';
import 'package:figmine/src/config/yaml_reader.dart';

/// The `color_scheme` section of `figmine.yaml`.
final class SchemeConfig {
  /// Creates ColorScheme settings.
  const factory({
    String? collection,
    String? seed,
    Map<String, String> roles,
    Map<String, String> extra,
    Map<String, ColorOverride> overrides,
  }) = SchemeConfig._;

  const new _({
    this.collection,
    this.seed,
    this.roles = const {},
    this.extra = const {},
    this.overrides = const {},
  });

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) => SchemeConfig(
    collection: yaml.string('collection'),
    seed: yaml.string('seed'),
    roles: yaml.stringMap('roles'),
    extra: yaml.stringMap('extra'),
    overrides: ColorOverrides.fromYaml(yaml),
  );

  /// Collection whose every color becomes a scheme field.
  final String? collection;

  /// Token name used as the seed for roles missing in Figma.
  final String? seed;

  /// Explicit Material role to token name mapping.
  final Map<String, String> roles;

  /// Extra scheme fields mapped to token names, such as `success`.
  final Map<String, String> extra;

  /// Colors set by hand, winning over Figma. Unknown names add fields.
  final Map<String, ColorOverride> overrides;
}
