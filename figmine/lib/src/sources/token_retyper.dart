import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/sources/token_value_parser.dart';
import 'package:figmine/src/sources/variables/alias_groups.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Gives numbers named for durations or font weights, and strings that
/// hold `cubic-bezier()` curves, their own types. Tokens linked by
/// aliases change together, also with tokens a file already types, so an
/// alias always has its target's type.
abstract final class TokenRetyper {
  static const Set<String> _strokes = {'stroke', 'border', 'outline', 'line'};

  /// [collections] with retyped tokens.
  static List<TokenCollection> apply(List<TokenCollection> collections) {
    final (tokens, groups) = AliasGroups.of(collections);
    final retype = <String, TokenType>{};
    for (final group in groups) {
      final members = [for (final k in group) tokens[k]!];
      final targets = members.map(_target).nonNulls.toSet();
      if (targets.length != 1) continue;
      final target = targets.single;
      final fits = members.every(
        (t) => t.values.values.every(
          (v) => TokenValueParser.parse(v.value, target) != null,
        ),
      );
      if (fits) retype.addAll({for (final k in group) k: target});
    }
    if (retype.isEmpty) return collections;
    return [
      for (final c in collections)
        TokenCollection(
          name: c.name,
          modes: c.modes,
          tokens: [
            for (final t in c.tokens)
              _retyped(t, retype[AliasGroups.key(c.name, t.path)]),
          ],
        ),
    ];
  }

  static const Set<TokenType> _typed = {
    TokenType.duration,
    TokenType.curve,
    TokenType.fontWeight,
  };

  static TokenType? _target(DesignToken t) {
    if (_typed.contains(t.type)) return t.type;
    final words = DartIdentifier.words(t.path).toSet();
    if (t.type == TokenType.number) {
      if (words.contains('duration') || words.contains('durations')) {
        return TokenType.duration;
      }
      final stroke = words.intersection(_strokes).isNotEmpty;
      if (words.contains('weight') && !stroke) return TokenType.fontWeight;
    }
    final curve = t.values.values.any(
      (v) => TokenValueParser.parse(v.value, TokenType.curve) != null,
    );
    if (t.type == TokenType.string && curve) return TokenType.curve;
    return null;
  }

  static DesignToken _retyped(DesignToken t, TokenType? type) => type == null
      ? t
      : DesignToken(
          path: t.path,
          type: type,
          description: t.description,
          variableId: t.variableId,
          values: {
            for (final MapEntry(key: mode, value: v) in t.values.entries)
              mode: TokenValue(
                TokenValueParser.parse(v.value, type)!,
                alias: v.alias,
              ),
          },
        );
}
