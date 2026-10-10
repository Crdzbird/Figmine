import 'dart:math' as math;

import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/codegen/role_order.dart';
import 'package:figmine/src/codegen/text_style_traits.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Maps text styles onto TextTheme roles.
abstract final class TypographyRoles {
  /// Returns the style of each TextTheme role found in Figma.
  ///
  /// Explicit `typography.roles` win. Then a style matches when its whole
  /// name or its last segment names the role, such as `Display/Large`.
  /// Remaining roles get the closest styles, best pairs first: styles named
  /// like the role, such as `Body/...`, within half the role size, then any
  /// within 6 points. Plain styles rank before italic, link and code ones,
  /// private styles are skipped, and larger roles get larger styles.
  static Map<String, TextStyleToken> match(
    List<TextStyleToken> all,
    TypographyConfig config,
  ) {
    final byName = {for (final style in all) style.name: style};
    final styles = TextStyleTraits.distinct(
      all.where((s) => !TextStyleTraits.isPrivate(s)),
    );
    for (final entry in config.roles.entries) {
      if (!MaterialRoles.textTheme.contains(entry.key)) {
        throw ConfigException('Unknown TextTheme role `${entry.key}`.');
      }
      if (!byName.containsKey(entry.value)) {
        throw ConfigException('Text style `${entry.value}` was not found.');
      }
    }
    final matched = {
      for (final role in MaterialRoles.textTheme)
        role: ?(byName[config.roles[role]] ?? _auto(styles, role)),
    };
    final used = matched.values.toSet();
    for (final named in const [true, false]) {
      final pairs = [
        for (var i = 0; i < MaterialRoles.textTheme.length; i++)
          if (!matched.containsKey(MaterialRoles.textTheme[i]))
            for (final style in styles)
              if (!used.contains(style) && (!named || _named(i, style)))
                (_score(style, MaterialRoles.textSpecs[i]), i, style),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      for (final (score, i, style) in pairs) {
        final role = MaterialRoles.textTheme[i];
        final size = MaterialRoles.textSpecs[i].$1;
        final limit = named ? math.max(6, size / 2) : 6;
        if (score >= limit ||
            matched.containsKey(role) ||
            used.contains(style)) {
          continue;
        }
        matched[role] = style;
        used.add(style);
      }
    }
    final sorted = RoleOrder.sorted(matched);
    return {for (final r in MaterialRoles.textTheme) r: ?sorted[r]};
  }

  static final Map<String, RegExp> _kinds = {
    'display': RegExp('display|hero'),
    'headline': RegExp(r'(?<!sub)heading|headline|\bh\d'),
    'title': RegExp('title|subheading|subtitle'),
    'body': RegExp('body|paragraph'),
    'label': RegExp('label|caption|button|action'),
  };

  static bool _named(int role, TextStyleToken style) {
    final kind = MaterialRoles.textTheme[role].replaceAll(
      RegExp(r'(Large|Medium|Small)$'),
      '',
    );
    return _kinds[kind]!.hasMatch(style.name.toLowerCase());
  }

  static double _score(TextStyleToken style, (double, int) spec) {
    final (size, weight) = spec;
    final weightGap = (style.fontWeight >= 500) == (weight >= 500) ? 0 : 3;
    return (style.fontSize - size).abs() +
        weightGap +
        TextStyleTraits.penalty(style);
  }

  static TextStyleToken? _auto(List<TextStyleToken> styles, String role) {
    for (final style in styles) {
      if (DartIdentifier.camel(style.path) == role) return style;
    }
    for (final style in styles) {
      if (DartIdentifier.camel([style.path.last]) == role) return style;
    }
    return null;
  }
}
