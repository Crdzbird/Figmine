import 'package:figmine/src/codegen/overlay_fit.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/state_extrapolation.dart';
import 'package:figmine/src/codegen/state_fallback.dart';
import 'package:figmine/src/codegen/state_field_specs.dart';
import 'package:figmine/src/codegen/state_readable.dart';
import 'package:figmine/src/inference/color_math.dart';

/// A color painted over a base, in light and dark mode.
typedef Overlay = ({String name, int light, int dark});

/// Gives single mode state colors a dark value.
abstract final class StateDark {
  /// Largest channel error accepted for a fitted relation.
  static const double tolerance = 0.03;

  /// [field] with a dark value that keeps its relation to a base in [by],
  /// such as the resting `button` with 20% black over it, or the Material
  /// default dark value when no relation fits or the relation would lose
  /// more than half the contrast with the base, such as an outline that
  /// disappears on a dark field. The surface relation only describes
  /// disabled states. [doc] describes the light value.
  static SchemeField apply(
    StateSpec spec,
    SchemeField field,
    Map<String, SchemeField> by,
    String doc,
  ) {
    final (rest, onRest) = StateFieldSpecs.rest(spec);
    const black = (
      name: 'black',
      light: ColorMath.black,
      dark: ColorMath.black,
    );
    const white = (
      name: 'white',
      light: ColorMath.white,
      dark: ColorMath.white,
    );
    ({String note, int dark})? best;
    var error = tolerance;
    for (final (base, overlay) in <(SchemeField?, Overlay?)>[
      (by[rest], black),
      (by[rest], white),
      (by[rest], _overlay(by[onRest])),
      if (spec.key.contains('disabled'))
        (by['surface'], _overlay(by['onSurface'])),
    ]) {
      if (base == null || overlay == null || base.name == spec.name) continue;
      if (!StateExtrapolation.opaque(base)) continue;
      final (opacity, miss) = OverlayFit.fit(
        base.lightArgb,
        overlay.light,
        field.lightArgb,
      );
      if (miss > error) continue;
      final dark = OverlayFit.blend(base.darkArgb, overlay.dark, opacity);
      final before = ColorMath.contrast(field.lightArgb, base.lightArgb);
      final after = ColorMath.contrast(dark, base.darkArgb);
      if (before >= 1.5 && after < before / 2) continue;
      error = miss;
      final percent = (opacity * 100).round();
      best = (
        note: '`${base.name}` with $percent% ${overlay.name} over it',
        dark: dark,
      );
    }
    best ??= StateExtrapolation.toneShift(spec, field, by[rest]);
    final chosen = best?.dark ?? StateFallback.material(spec, by).darkArgb;
    final readable = StateReadable.fix(spec, field, chosen, by[rest]);
    final dark = readable ?? chosen;
    final note = readable != null && readable != chosen
        ? 'its own hue at a tone that reads on `$rest`'
        : (best == null ? 'the Material default' : best.note);
    return (
      name: field.name,
      doc: '$doc The dark value is $note.',
      light: field.light,
      dark: StateFallback.literal(dark),
      lightArgb: field.lightArgb,
      darkArgb: dark,
    );
  }

  static Overlay? _overlay(SchemeField? f) => f == null
      ? null
      : (name: '`${f.name}`', light: f.lightArgb, dark: f.darkArgb);
}
