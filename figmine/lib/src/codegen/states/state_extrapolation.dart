import 'package:figmine/src/codegen/scheme/overlay_fit.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/states/state_dark.dart';
import 'package:figmine/src/codegen/states/state_fallback.dart';
import 'package:figmine/src/codegen/states/state_field_specs.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Derives state colors Figma lacks from the states it has.
abstract final class StateExtrapolation {
  /// Whether [field] is opaque in both modes, so colors can relate to it.
  static bool opaque(SchemeField field) =>
      ColorMath.alpha(field.lightArgb) >= 1 &&
      ColorMath.alpha(field.darkArgb) >= 1;

  /// Opacity of the Material hover state layer.
  static const double hover = 0.08;

  /// [spec], a pressed or focused fill, as the relation the hovered fill
  /// [hovered] has with the resting fill in each mode, strengthened the way
  /// Material strengthens hover to pressed. Null when no relation fits.
  static SchemeField? follow(
    StateSpec spec,
    SchemeField hovered,
    Map<String, SchemeField> by,
  ) {
    final (rest, onRest) = StateFieldSpecs.rest(spec);
    final base = by[rest];
    final label = by[onRest];
    if (base == null || spec.overlay == null) return null;
    if (!opaque(base)) return null;
    for (final overlay in <Overlay>[
      (name: 'black', light: ColorMath.black, dark: ColorMath.black),
      (name: 'white', light: ColorMath.white, dark: ColorMath.white),
      if (label != null)
        (name: '`${label.name}`', light: label.lightArgb, dark: label.darkArgb),
    ]) {
      final (lightOpacity, lightMiss) = OverlayFit.fit(
        base.lightArgb,
        overlay.light,
        hovered.lightArgb,
      );
      final (darkOpacity, darkMiss) = OverlayFit.fit(
        base.darkArgb,
        overlay.dark,
        hovered.darkArgb,
      );
      final miss = lightMiss > darkMiss ? lightMiss : darkMiss;
      if (miss > StateDark.tolerance || lightOpacity == 0) continue;
      double strong(double o) => (o * spec.opacity / hover).clamp(0.0, 1.0);
      final light = OverlayFit.blend(
        base.lightArgb,
        overlay.light,
        strong(lightOpacity),
      );
      final dark = OverlayFit.blend(
        base.darkArgb,
        overlay.dark,
        strong(darkOpacity),
      );
      final percent = (strong(lightOpacity) * 100).round();
      return (
        name: spec.name,
        doc:
            'Follows the hovered variant in Figma: `${base.name}` with '
            '$percent% ${overlay.name} over it.',
        light: StateFallback.literal(light),
        dark: StateFallback.literal(dark),
        lightArgb: light,
        darkArgb: dark,
      );
    }
    return null;
  }

  /// The dark resting fill moved by the tone the light state fill moves
  /// from the light resting fill, which keeps the direction and order of
  /// states, such as pressed darker than hovered. Only for state fills.
  static ({String note, int dark})? toneShift(
    StateSpec spec,
    SchemeField field,
    SchemeField? rest,
  ) {
    if (rest == null || rest.name == spec.name) return null;
    if (!opaque(rest)) return null;
    if (spec.key.contains('disabled') || !spec.key.endsWith('.fill')) {
      return null;
    }
    final shift =
        Hct.fromInt(field.lightArgb).tone - Hct.fromInt(rest.lightArgb).tone;
    final dark = Hct.fromInt(rest.darkArgb);
    final tone = (dark.tone + shift).clamp(0.0, 100.0);
    return (
      note: '`${rest.name}` moved ${shift.round()} in tone, as in light',
      dark: Hct.from(dark.hue, dark.chroma, tone).toInt(),
    );
  }
}
