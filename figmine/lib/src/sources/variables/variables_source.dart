import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/sources/variables/variable_resolver.dart';
import 'package:figmine/src/sources/variables/variable_token_reader.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Reads local variable collections.
final class VariablesSource {
  /// Creates a source that reads with [client].
  const factory({required FigmaClient client, required TokensConfig config}) =
      VariablesSource._;

  const new _({required this.client, required this.config});

  /// The Figma client.
  final FigmaClient client;

  /// Token settings.
  final TokensConfig config;

  /// Fetches every local collection of [fileKey], sorted by name.
  Future<List<TokenCollection>> fetch(String fileKey) async {
    final json = await client.getJson('/v1/files/$fileKey/variables/local');
    final meta = Json.map(json['meta']);
    final resolver = VariableResolver(
      variables: Json.map(meta['variables']),
      collections: Json.map(meta['variableCollections']),
    );
    final reader = VariableTokenReader(resolver: resolver, config: config);
    final result = <TokenCollection>[];
    for (final entry in resolver.collections.entries) {
      final collection = Json.map(entry.value);
      final name = '${collection['name']}';
      if (collection['remote'] == true || !config.includes(name)) continue;
      final modes = CollectionModes.names(collection);
      if (modes.isEmpty) continue;
      final tokens = <String, DesignToken>{};
      for (final variable in resolver.variables.entries) {
        final data = Json.map(variable.value);
        if (data['variableCollectionId'] != entry.key) continue;
        if (data['remote'] == true) continue;
        final token = reader.read(variable.key, modes);
        if (token != null) tokens.putIfAbsent(token.name, () => token);
      }
      final sorted = tokens.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      result.add(TokenCollection(name: name, modes: modes, tokens: sorted));
    }
    return result..sort((a, b) => a.name.compareTo(b.name));
  }
}
