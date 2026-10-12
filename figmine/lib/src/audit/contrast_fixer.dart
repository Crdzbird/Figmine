import 'package:figmine/src/audit/contrast_finding.dart';
import 'package:figmine/src/audit/contrast_fix.dart';
import 'package:figmine/src/audit/fix_builder.dart';
import 'package:figmine/src/audit/fix_candidates.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/inference/color/color_math.dart';

/// Suggests fixes for failing contrast pairs.
abstract final class ContrastFixer {
  static final RegExp _outline = RegExp('border|stroke|outline|divider');

  static final RegExp _text = RegExp('text|foreground|content|icon');

  static final RegExp _state = RegExp(
    'disabled|hover|pressed|focus|selected|active|inverse|error|danger',
  );

  /// A fix for each of [findings], in order. The pairs of one foreground
  /// and background share a token: of the [tokens], the one closest to
  /// the foreground that passes in every failing mode, preferring tokens
  /// named for the same use, not for a state such as disabled, and ones
  /// that pass in both modes against [fields]. Without one, the foreground
  /// moves in tone.
  static List<ContrastFix?> suggest(
    List<ContrastFinding> findings,
    List<SchemeField> fields,
    List<FixCandidate> tokens,
  ) {
    final by = {for (final f in fields) f.name: f};
    final groups = <String, List<ContrastFinding>>{};
    for (final f in findings) {
      (groups['${f.foreground}|${f.background}'] ??= []).add(f);
    }
    final chosen = {
      for (final e in groups.entries)
        e.key: _token(e.value, by[e.value.first.background], tokens),
    };
    return [
      for (final f in findings)
        FixBuilder.token(f, chosen['${f.foreground}|${f.background}'], by) ??
            FixBuilder.tone(f),
    ];
  }

  static FixCandidate? _token(
    List<ContrastFinding> pairs,
    SchemeField? background,
    List<FixCandidate> tokens,
  ) {
    if (background == null) return null;
    final first = pairs.first;
    final use = first.foreground.startsWith('outline') ? _outline : _text;
    bool passes(FixCandidate t, String mode) =>
        ColorMath.contrast(
          mode == 'dark' ? t.dark : t.light,
          mode == 'dark' ? background.darkArgb : background.lightArgb,
        ) >=
        first.required;
    double score(FixCandidate t) {
      final name = t.name.toLowerCase();
      final distance = pairs.fold<double>(
        0,
        (sum, f) =>
            sum +
            FixCandidates.distance(
              f.mode == 'dark' ? t.dark : t.light,
              f.foregroundArgb,
            ),
      );
      return distance +
          (use.hasMatch(name) ? 0 : 20) +
          (_state.hasMatch(name) ? 25 : 0) +
          (passes(t, 'light') && passes(t, 'dark') ? 0 : 10);
    }

    final fits =
        tokens.where((t) => pairs.every((f) => passes(t, f.mode))).toList()
          ..sort((a, b) => score(a).compareTo(score(b)));
    return fits.firstOrNull;
  }
}
