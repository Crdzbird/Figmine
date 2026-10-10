import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/dtcg/dtcg_entry.dart';
import 'package:figmine/src/sources/dtcg/dtcg_resolver.dart';
import 'package:figmine/src/sources/dtcg/dtcg_types.dart';
import 'package:figmine/src/sources/dtcg/dtcg_typography.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_ref.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Collections and text styles read from design token files.
typedef DtcgTokens = ({
  List<TokenCollection> collections,
  List<TextStyleToken> textStyles,
});

/// Turns resolved entries into figmine tokens.
abstract final class DtcgBuilder {
  /// Builds collections and text styles from [entries].
  static DtcgTokens build(
    List<DtcgEntry> entries,
    Map<String, List<String>> modes,
    TokensConfig config,
  ) {
    final resolver = DtcgResolver(entries, modes);
    final collections = <TokenCollection>[];
    for (final MapEntry(key: name, value: names) in modes.entries) {
      if (!config.includes(name)) continue;
      final byPath = <String, Map<String, DtcgEntry>>{};
      for (final e in entries.where((e) => e.collection == name)) {
        byPath.putIfAbsent(e.path.join('.'), () => {})[e.mode] = e;
      }
      final tokens = [
        for (final perMode in byPath.values)
          ?_token(perMode, names, resolver, config),
      ]..sort((a, b) => a.name.compareTo(b.name));
      if (tokens.isNotEmpty) {
        collections.add(
          TokenCollection(name: name, modes: names, tokens: tokens),
        );
      }
    }
    return (
      collections: collections,
      textStyles: DtcgTypography.collect(entries, resolver, config),
    );
  }

  static DesignToken? _token(
    Map<String, DtcgEntry> perMode,
    List<String> modes,
    DtcgResolver resolver,
    TokensConfig config,
  ) {
    final first = perMode[modes.first] ?? perMode.values.first;
    final values = <String, TokenValue>{};
    TokenType? type;
    for (final mode in modes) {
      final entry = perMode[mode] ?? first;
      final resolved = resolver.resolve(entry);
      type ??= DtcgTypes.of(
        entry.type.isEmpty ? resolved?.type ?? '' : entry.type,
      );
      final value = DtcgTypes.parse(type, resolved?.value ?? entry.fallback);
      if (type == null || value == null) return null;
      final target = resolver.target(entry);
      values[mode] = TokenValue(
        value,
        alias: target == null
            ? null
            : TokenRef(
                collection: target.collection,
                path: config.pathOf(target.path.join('/')),
                mode: (resolver.modes[target.collection]?.length ?? 0) > 1
                    ? target.mode
                    : null,
              ),
      );
    }
    final path = config.pathOf(first.path.join('/'));
    if (path.isEmpty || type == null) return null;
    return DesignToken(
      path: path,
      type: type,
      values: values,
      description: first.description,
      variableId: first.variableId,
    );
  }
}
