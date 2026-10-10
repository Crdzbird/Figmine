import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/yaml_reader.dart';

/// The `tokens` section of `figmine.yaml`.
final class TokensConfig {
  /// Creates token settings.
  const factory({
    TokenSource source,
    Map<String, String?> collections,
    List<String> files,
    String stripPrefix,
    String lightMode,
    String darkMode,
  }) = TokensConfig._;

  const new _({
    this.source = TokenSource.auto,
    this.collections = const {},
    this.files = const [],
    this.stripPrefix = '',
    this.lightMode = 'light',
    this.darkMode = 'dark',
  });

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) => TokensConfig(
    source: TokenSource.parse(yaml.string('source')),
    collections: yaml.nameMap('collections'),
    files: yaml.strings('files'),
    stripPrefix: yaml.string('strip_prefix') ?? '',
    lightMode: yaml.string('light_mode') ?? 'light',
    darkMode: yaml.string('dark_mode') ?? 'dark',
  );

  /// Where tokens are read from.
  final TokenSource source;

  /// Collections to include, mapped to their class name segment.
  ///
  /// Empty means every local collection. A null segment uses the collection
  /// name, an empty one adds no segment.
  final Map<String, String?> collections;

  /// Design token JSON files or folders, relative to the project.
  final List<String> files;

  /// Prefix removed from token names, for example `color/`.
  final String stripPrefix;

  /// Mode name, or style folder, that holds light values.
  final String lightMode;

  /// Mode name, or style folder, that holds dark values.
  final String darkMode;

  /// Whether the collection called [name] is generated.
  bool includes(String name) =>
      collections.isEmpty || collections.containsKey(name);

  /// The class name segment of the collection called [name].
  String segmentOf(String name) => collections[name] ?? name;

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
