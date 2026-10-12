import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/sources/styles/style_colors.dart';
import 'package:figmine/src/sources/variables/variables_source.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Reads token collections from the configured [TokenSource].
final class CollectionsFetcher {
  /// Creates a fetcher over Variables and the style catalog.
  const factory({
    required TokensConfig config,
    required VariablesSource variables,
    required Future<List<StyleNode>> Function() styles,
    required void Function(String message) log,
  }) = CollectionsFetcher._;

  const new _({
    required this.config,
    required this.variables,
    required this.styles,
    required this.log,
  });

  /// Token settings.
  final TokensConfig config;

  /// The Variables source.
  final VariablesSource variables;

  /// Loads the style catalog, at most once.
  final Future<List<StyleNode>> Function() styles;

  /// Receives progress messages.
  final void Function(String message) log;

  /// Fetches the collections of [fileKey].
  Future<List<TokenCollection>> fetch(String fileKey) =>
      switch (config.source) {
        TokenSource.variables => variables.fetch(fileKey),
        TokenSource.styles => _styles(const []),
        TokenSource.auto || TokenSource.file => _auto(fileKey),
      };

  Future<List<TokenCollection>> _auto(String fileKey) async {
    try {
      final collections = await variables.fetch(fileKey);
      final hasColors = collections.any(
        (c) => c.tokens.any((t) => t.type == TokenType.color),
      );
      if (hasColors) return collections;
      log('No color variables found, adding color styles.');
      return await _styles(collections);
    } on FigmaException catch (error) {
      if (error.statusCode != 403 && error.statusCode != 404) rethrow;
      log('Variables API unavailable (${error.statusCode}), reading styles.');
    }
    return await _styles(const []);
  }

  Future<List<TokenCollection>> _styles(List<TokenCollection> base) async {
    final collection = StyleColors.collect(await styles(), config);
    return [...base, ?collection];
  }
}
