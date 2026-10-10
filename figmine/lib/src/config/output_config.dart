import 'package:figmine/src/config/output_layout.dart';
import 'package:figmine/src/config/yaml_reader.dart';

/// The `output` section of `figmine.yaml`.
final class OutputConfig {
  /// Creates output settings.
  const factory({
    String directory,
    String themeDirectory,
    String classPrefix,
    String? materialImport,
    OutputLayout layout,
  }) = OutputConfig._;

  const new _({
    this.directory = 'lib/theme/tokens',
    this.themeDirectory = 'lib/theme',
    this.classPrefix = 'App',
    this.materialImport,
    this.layout = OutputLayout.domain,
  });

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) => OutputConfig(
    directory: yaml.string('directory') ?? 'lib/theme/tokens',
    themeDirectory: yaml.string('theme_directory') ?? 'lib/theme',
    classPrefix: yaml.string('class_prefix') ?? 'App',
    materialImport: yaml.string('material_import'),
    layout: OutputLayout.parse(yaml.string('layout')),
  );

  /// Directory that receives generated token files. Rewritten on sync.
  final String directory;

  /// Directory that receives the theme scaffold. Written once.
  final String themeDirectory;

  /// Prefix of every generated class, for example `App`.
  final String classPrefix;

  /// Import that provides Material. Detected from pubspec when null.
  final String? materialImport;

  /// How generated token files are organized into folders.
  final OutputLayout layout;
}
