import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/dtcg/dtcg_entry.dart';
import 'package:figmine/src/sources/dtcg/dtcg_resolver.dart';
import 'package:figmine/src/sources/dtcg/dtcg_values.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Reads DTCG `typography` composite tokens as text styles.
abstract final class DtcgTypography {
  /// Text styles from the first mode that defines each typography token.
  static List<TextStyleToken> collect(
    List<DtcgEntry> entries,
    DtcgResolver resolver,
    TokensConfig config,
  ) {
    final styles = <TextStyleToken>[];
    final seen = <String>{};
    int rank(DtcgEntry e) => resolver.modes[e.collection]?.indexOf(e.mode) ?? 0;
    final typography = entries.where((e) => e.type == 'typography').toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));
    for (final entry in typography) {
      if (!seen.add('${entry.collection}|${entry.path.join('.')}')) continue;
      final value = Json.map(resolver.resolve(entry)?.value);
      Object? part(String key) {
        final raw = value[key];
        final alias = (
          collection: entry.collection,
          mode: entry.mode,
          path: entry.path,
          type: '',
          value: raw,
          description: '',
          aliasCollection: null,
          fallback: null,
          variableId: null,
        );
        return resolver.resolve(alias)?.value ?? raw;
      }

      final family = DtcgValues.string(part('fontFamily'));
      final size = DtcgValues.number(part('fontSize'));
      if (family == null || size == null || size <= 0) continue;
      final line = DtcgValues.number(part('lineHeight'));
      styles.add(
        TextStyleToken(
          path: config.pathOf(entry.path.join('/')),
          fontFamily: family,
          fontSize: size,
          fontWeight: DtcgValues.weight(part('fontWeight')) ?? 400,
          height: line == null ? null : (line > 4 ? line / size : line),
          letterSpacing: DtcgValues.number(part('letterSpacing')),
          italic: part('fontStyle') == 'italic',
          decoration: switch (part('textDecoration')) {
            'underline' => 'underline',
            'line-through' => 'lineThrough',
            _ => null,
          },
          description: entry.description,
        ),
      );
    }
    return styles..sort((a, b) => a.name.compareTo(b.name));
  }
}
