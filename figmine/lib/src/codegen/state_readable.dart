import 'dart:math' as math;

import 'package:figmine/src/audit/tone_fix.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/state_field_specs.dart';
import 'package:figmine/src/inference/color_math.dart';

/// Keeps the text, icons and outlines of a component readable on its
/// resting fill in dark mode.
abstract final class StateReadable {
  /// The contrast [field] needs on [rest] in dark mode: what it has in
  /// light mode, up to 4.5:1 for text and icons and 3:1 for outlines, or
  /// null when [spec] is a fill or has no resting fill.
  static double? need(StateSpec spec, SchemeField field, SchemeField? rest) {
    if (rest == null || rest.name == spec.name) return null;
    if (spec.key.endsWith('.fill')) return null;
    final light = ColorMath.contrast(field.lightArgb, rest.lightArgb);
    return math.min(light, spec.key.endsWith('.stroke') ? 3.0 : 4.5);
  }

  /// Whether [dark] reads on the dark [rest] as well as [field] needs.
  static bool keeps(
    StateSpec spec,
    SchemeField field,
    int dark,
    SchemeField? rest,
  ) {
    final needed = need(spec, field, rest);
    if (needed == null) return true;
    return ColorMath.contrast(dark, rest!.darkArgb) >= needed - 0.01;
  }

  /// [dark] when it reads on the dark [rest], otherwise the light color of
  /// [field] at the nearest tone that does, or null when none does.
  static int? fix(
    StateSpec spec,
    SchemeField field,
    int dark,
    SchemeField? rest,
  ) {
    if (keeps(spec, field, dark, rest)) return dark;
    return ToneFix.nearest(
      field.lightArgb,
      rest!.darkArgb,
      need(spec, field, rest)!,
    );
  }
}
