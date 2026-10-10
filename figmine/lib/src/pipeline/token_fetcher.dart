import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/figma/figma_version.dart';
import 'package:figmine/src/pipeline/canvas_fetcher.dart';
import 'package:figmine/src/pipeline/file_meta_reader.dart';
import 'package:figmine/src/pipeline/token_assembler.dart';
import 'package:figmine/src/sources/collections_fetcher.dart';
import 'package:figmine/src/sources/dtcg/file_tokens.dart';
import 'package:figmine/src/sources/style_catalog.dart';
import 'package:figmine/src/sources/style_effects.dart';
import 'package:figmine/src/sources/style_refs.dart';
import 'package:figmine/src/sources/token_retyper.dart';
import 'package:figmine/src/sources/variables_source.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Reads file metadata and tokens from Figma.
final class TokenFetcher {
  /// Creates a fetcher for the file in [config].
  const factory({
    required FigmaClient client,
    required FigmineConfig config,
    required void Function(String message) log,
    String root,
    bool offline,
  }) = TokenFetcher._;

  const new _({
    required this.client,
    required this.config,
    required this.log,
    this.root = '.',
    this.offline = false,
  });

  /// Whether to read only the lock file, the cache and the project.
  final bool offline;

  /// Project folder that token files are relative to.
  final String root;

  /// The Figma client.
  final FigmaClient client;

  /// The project configuration.
  final FigmineConfig config;

  /// Receives progress messages.
  final void Function(String message) log;

  /// The file name and current version: from the lock file offline,
  /// otherwise from Figma.
  Future<FigmaFileMeta> meta() => _meta.read();

  /// Versions saved after [since]; none offline.
  Future<List<FigmaVersion>> versions(String? since) => _meta.versions(since);

  FileMetaReader get _meta => FileMetaReader(
    client: client,
    config: config,
    root: root,
    offline: offline,
  );

  /// Fetches collections, styles, screens and icons, and assembles them.
  ///
  /// Heavy reads are cached for the version in [meta].
  Future<TokenSet> fetch(FigmaFileMeta meta) async {
    final key = config.fileKey;
    await client.cache?.pin(key, meta.version);
    final canvas = CanvasFetcher(client: client, config: config, log: log);
    final screens = await canvas.screens(offline: offline);
    final files = await FileTokens.load(root, config.tokens);
    Future<List<StyleNode>>? pending;
    Future<List<StyleNode>> styles() => pending ??= StyleCatalog(
      client: client,
      refs: StyleRefs(client: client, library: config.library, log: log),
    ).fetch(key, screens: screens);
    final collections =
        files?.collections ??
        await CollectionsFetcher(
          config: config.tokens,
          variables: VariablesSource(client: client, config: config.tokens),
          styles: styles,
          log: log,
        ).fetch(key);
    final fileStyles = files?.textStyles ?? const [];
    final loaded = config.typography.enabled || pending != null
        ? await styles()
        : const <StyleNode>[];
    return TokenAssembler(config: config, log: log).assemble(
      meta: meta,
      collections: TokenRetyper.apply(StyleEffects.addTo(collections, loaded)),
      styles: config.typography.enabled ? loaded : const [],
      fileTextStyles: fileStyles,
      screens: screens,
      icons: await canvas.icons(offline: offline, root: root),
    );
  }
}
