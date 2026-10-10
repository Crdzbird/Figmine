import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/collection_modes.dart';
import 'package:figmine/src/sources/token_value_parser.dart';
import 'package:figmine/src/sources/variable_resolver.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_ref.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Turns one Figma variable into a [DesignToken].
final class VariableTokenReader {
  /// Creates a reader over [resolver].
  const factory({
    required VariableResolver resolver,
    required TokensConfig config,
  }) = VariableTokenReader._;

  const new _({required this.resolver, required this.config});

  /// Resolves values and aliases.
  final VariableResolver resolver;

  /// Token settings.
  final TokensConfig config;

  /// Reads the variable [id] in every one of [modes].
  ///
  /// Returns null for unsupported types or unresolvable values.
  DesignToken? read(String id, List<String> modes) {
    final variable = resolver.variable(id);
    final type = TokenType.fromFigma(variable['resolvedType']);
    final path = config.pathOf('${variable['name'] ?? ''}');
    if (type == null || path.isEmpty) return null;
    final values = <String, TokenValue>{};
    for (final mode in modes) {
      final value = TokenValueParser.parse(resolver.resolve(id, mode), type);
      if (value == null) return null;
      values[mode] = TokenValue(value, alias: _ref(id, mode));
    }
    return DesignToken(
      path: path,
      type: type,
      values: values,
      description: '${variable['description'] ?? ''}'.trim(),
      variableId: id,
    );
  }

  TokenRef? _ref(String id, String mode) {
    final target = VariableResolver.aliasOf(resolver.raw(id, mode));
    if (target == null) return null;
    final collection = resolver.collectionOf(target);
    final modes = CollectionModes.names(collection);
    return TokenRef(
      collection: '${collection['name'] ?? 'remote'}',
      path: config.pathOf('${resolver.variable(target)['name'] ?? target}'),
      mode: modes.length > 1
          ? CollectionModes.resolve(collection, mode)?.name
          : null,
    );
  }
}
