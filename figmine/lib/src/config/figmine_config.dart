import 'package:figmine/src/config/component_pins.dart';
import 'package:figmine/src/config/file_key.dart';
import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/config/library_config.dart';
import 'package:figmine/src/config/output_config.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/config/yaml_reader.dart';

/// The parsed contents of `figmine.yaml`.
final class FigmineConfig {
  /// Creates a configuration.
  const factory({
    required String fileKey,
    String tokenEnv,
    TokensConfig tokens,
    SchemeConfig scheme,
    TypographyConfig typography,
    InferenceConfig inference,
    LibraryConfig library,
    IconsConfig? icons,
    OutputConfig output,
    String lockFile,
    Map<String, double> components,
  }) = FigmineConfig._;

  const new _({
    required this.fileKey,
    this.tokenEnv = 'FIGMA_TOKEN',
    this.tokens = const TokensConfig(),
    this.scheme = const SchemeConfig(),
    this.typography = const TypographyConfig(),
    this.inference = const InferenceConfig(),
    this.library = const LibraryConfig(),
    this.icons,
    this.output = const OutputConfig(),
    this.lockFile = 'figmine.lock.json',
    this.components = const {},
  });

  /// Builds a configuration from the root YAML map.
  ///
  /// The `colors` section of earlier versions is read as `tokens`.
  factory fromYaml(Map<Object?, Object?> root) {
    final yaml = YamlReader(root, 'figmine');
    final figma = yaml.child('figma');
    return FigmineConfig(
      fileKey: FileKey.parse(figma.requireString('file_key')),
      tokenEnv: figma.string('token_env') ?? 'FIGMA_TOKEN',
      tokens: TokensConfig.fromYaml(
        yaml.optionalChild('tokens') ?? yaml.child('colors'),
      ),
      scheme: SchemeConfig.fromYaml(yaml.child('color_scheme')),
      typography: TypographyConfig.fromYaml(yaml.child('typography')),
      inference: InferenceConfig.fromYaml(yaml.child('inference')),
      library: LibraryConfig.fromYaml(yaml.child('library')),
      icons: IconsConfig.fromYaml(yaml.optionalChild('icons')),
      output: OutputConfig.fromYaml(yaml.child('output')),
      lockFile: yaml.string('lock_file') ?? 'figmine.lock.json',
      components: ComponentPins.fromYaml(yaml.optionalChild('components')),
    );
  }

  /// The key from the Figma URL, `figma.com/design/<key>/...`.
  final String fileKey;

  /// Environment variable that holds the Figma access token.
  final String tokenEnv;

  /// Token settings.
  final TokensConfig tokens;

  /// ColorScheme mapping settings.
  final SchemeConfig scheme;

  /// Text style settings.
  final TypographyConfig typography;

  /// Settings for inferring tokens from screens.
  final InferenceConfig inference;

  /// Design system libraries to read styles from.
  final LibraryConfig library;

  /// Icon export settings, or null when icons are not exported.
  final IconsConfig? icons;

  /// Generated code settings.
  final OutputConfig output;

  /// Lock file path, relative to the project.
  final String lockFile;

  /// Component dimensions set by hand, by metric name.
  final Map<String, double> components;
}
