import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/config/yaml_reader.dart';

/// The `inference` section of `figmine.yaml`.
final class InferenceConfig {
  /// Creates inference settings.
  const factory({
    InferenceMode mode,
    List<String> pages,
    List<String> excludePages,
    List<String> nodeIds,
    int maxFrames,
  }) = InferenceConfig._;

  const new _({
    this.mode = InferenceMode.auto,
    this.pages = const [],
    this.excludePages = defaultExcludes,
    this.nodeIds = const [],
    this.maxFrames = 150,
  });

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) {
    final excludes = yaml.strings('exclude_pages');
    return InferenceConfig(
      mode: InferenceMode.parse(yaml.string('mode')),
      pages: yaml.strings('pages'),
      excludePages: yaml.map.containsKey('exclude_pages')
          ? excludes
          : defaultExcludes,
      nodeIds: [
        for (final id in yaml.strings('node_ids')) id.replaceAll('-', ':'),
      ],
      maxFrames: int.tryParse(yaml.string('max_frames') ?? '') ?? 150,
    );
  }

  /// Page name fragments skipped by default.
  static const List<String> defaultExcludes = [
    'cover',
    'archive',
    'old',
    'wip',
    'deprecated',
    'playground',
    'sandbox',
    'thumbnail',
  ];

  /// When tokens are inferred.
  final InferenceMode mode;

  /// Pages to analyze. Empty means every page not excluded.
  final List<String> pages;

  /// Pages whose name contains one of these are skipped, case insensitive.
  final List<String> excludePages;

  /// Frames to analyze. Overrides [pages] when set.
  final List<String> nodeIds;

  /// Upper bound of analyzed frames, keeping requests reasonable.
  final int maxFrames;

  /// Whether the page called [name] is analyzed.
  bool includesPage(String name) {
    final lower = name.toLowerCase();
    if (pages.isNotEmpty) return pages.any((p) => p.toLowerCase() == lower);
    return !excludePages.any((e) => lower.contains(e.toLowerCase()));
  }
}
