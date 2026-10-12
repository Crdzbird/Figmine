import 'package:figmine/src/codegen/scheme/overlay_fit.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/score/score_item.dart';
import 'package:figmine/src/score/theme_snapshot.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Grades a theme against a reference.
abstract final class Scorer {
  /// Every value of [reference] graded against [actual]. Colors compare by
  /// CAM16 distance as seen on the reference surface, so translucent state
  /// layers count by how they look, numbers within a tolerance, and text
  /// by family and size.
  static List<ScoreItem> grade(ThemeSnapshot reference, ThemeSnapshot actual) =>
      [
        for (final (section, expected, got, base) in [
          ('colors', reference.light, actual.light, ColorMath.white),
          ('dark colors', reference.dark, actual.dark, ColorMath.black),
        ])
          for (final e in expected.entries)
            _color(
              section,
              e.key,
              e.value,
              got[e.key],
              expected['surface'] ?? base,
            ),
        for (final e in reference.components.entries)
          _number(e.key, e.value, actual.components[e.key]),
        for (final e in reference.text.entries)
          _text(e.key, e.value, actual.text[e.key]),
      ];

  static ScoreItem _color(
    String section,
    String name,
    int want,
    int? got,
    int surface,
  ) {
    int seen(int c) =>
        OverlayFit.blend(surface, c | 0xFF000000, ColorMath.alpha(c));
    final distance = got == null
        ? null
        : Cam16.fromInt(seen(want)).distance(Cam16.fromInt(seen(got)));
    final grade = switch (distance) {
      null => Grade.missing,
      <= 1.5 => Grade.match,
      <= 6 => Grade.close,
      _ => Grade.off,
    };
    return (
      section: section,
      name: name,
      expected: ColorMath.hex(want),
      actual: got == null ? '-' : ColorMath.hex(got),
      grade: grade,
    );
  }

  static ScoreItem _number(String name, double want, double? got) {
    final gap = got == null ? null : (got - want).abs();
    final grade = switch (gap) {
      null => Grade.missing,
      0 => Grade.match,
      final g when g <= 2 || g <= want * 0.1 => Grade.close,
      _ => Grade.off,
    };
    String show(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';
    return (
      section: 'components',
      name: name,
      expected: show(want),
      actual: got == null ? '-' : show(got),
      grade: grade,
    );
  }

  static ScoreItem _text(String name, TextFacts want, TextFacts? got) {
    final family =
        want.family.isEmpty ||
        got?.family.toLowerCase() == want.family.toLowerCase();
    final size = want.size == 0 || got?.size == want.size;
    final grade = got == null
        ? Grade.missing
        : (family && size
              ? Grade.match
              : (family || size ? Grade.close : Grade.off));
    String show(TextFacts? t) =>
        t == null ? '-' : '${t.family} ${t.size.round()}'.trim();
    return (
      section: 'typography',
      name: name,
      expected: show(want),
      actual: show(got),
      grade: grade,
    );
  }
}
