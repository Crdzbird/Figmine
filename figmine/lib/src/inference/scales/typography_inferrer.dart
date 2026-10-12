import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/inference/stats/text_usage.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Maps the text styles used in the screens onto Material TextTheme roles.
abstract final class TypographyInferrer {
  static final RegExp _mono = RegExp('mono|code|courier|consolas|menlo');

  /// Assigns each common style to its closest free role, most used first.
  /// Large text of 32 points or more counts even when rare, as display
  /// text is, and may sit further from its role, up to a quarter of its
  /// size.
  /// Monospace families, which set code, are left out unless nothing else
  /// is used.
  static List<TextStyleToken> infer(Iterable<TextUsage> usages) {
    final all = _merge(usages);
    final total = all.fold(0, (sum, u) => sum + u.characters);
    if (total == 0) return const [];
    final common =
        all
            .where(
              (u) =>
                  u.characters / total >= 0.005 ||
                  (u.size >= 32 && u.layers >= 2),
            )
            .toList()
          ..sort((a, b) => b.characters.compareTo(a.characters));
    final plain = common.where((u) => !_mono.hasMatch(u.family.toLowerCase()));
    if (plain.isNotEmpty) common.retainWhere(plain.toList().contains);
    final assigned = <String, TextUsage>{};
    for (final usage in common) {
      final role = _closest(usage, assigned.keys.toSet());
      if (role != null) assigned[role] = usage;
    }
    return [
      for (final role in MaterialRoles.textTheme)
        if (assigned[role] case final u?)
          TextStyleToken(
            path: [role],
            fontFamily: u.family,
            fontSize: u.size,
            fontWeight: u.weight,
            height: u.height,
            letterSpacing: u.letterSpacing,
            description:
                'Inferred from ${u.layers} text layers, '
                '${u.characters} characters.',
          ),
    ];
  }

  static List<TextUsage> _merge(Iterable<TextUsage> usages) {
    final merged = <String, TextUsage>{};
    for (final u in usages) {
      final key = '${u.family}|${u.size}|${u.weight}';
      final p = merged[key];
      merged[key] = p == null
          ? u
          : (
              family: u.family,
              size: u.size,
              weight: u.weight,
              height: p.characters >= u.characters ? p.height : u.height,
              letterSpacing: u.letterSpacing,
              characters: p.characters + u.characters,
              layers: p.layers + u.layers,
            );
    }
    return merged.values.toList();
  }

  static String? _closest(TextUsage usage, Set<String> taken) {
    String? best;
    var bestScore = usage.size / 4 > 8 ? usage.size / 4 : 8.0;
    for (var i = 0; i < MaterialRoles.textSpecs.length; i++) {
      final role = MaterialRoles.textTheme[i];
      if (taken.contains(role)) continue;
      final (size, weight) = MaterialRoles.textSpecs[i];
      final weightGap = (usage.weight >= 500) == (weight >= 500) ? 0 : 3;
      final score = (usage.size - size).abs() + weightGap;
      if (score <= bestScore) {
        best = role;
        bestScore = score;
      }
    }
    return best;
  }
}
