import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/overlay_fit.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/state_field_specs.dart';
import 'package:figmine/src/codegen/value_expressions.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// Builds state fields from other fields of the scheme.
abstract final class StateFallback {
  /// [from] under the name [name], with its values and a new [doc].
  static SchemeField copy(String name, SchemeField from, String doc) => (
    name: name,
    doc: doc,
    light: from.light,
    dark: from.dark,
    lightArgb: from.lightArgb,
    darkArgb: from.darkArgb,
  );

  /// A literal color as a value.
  static ValueExpression literal(int argb) =>
      (code: DartSource.color(ColorValue.fromArgb(argb).hex), file: null);

  /// The Material default of [spec], built from the fields found so far.
  /// A `transparent` base gives a transparent color, or the overlay at
  /// its opacity, as a Material state layer on nothing.
  static SchemeField material(StateSpec spec, Map<String, SchemeField> by) {
    final overlay = spec.overlay == null ? null : by[spec.overlay];
    if (spec.base == 'transparent') return _layer(spec, overlay);
    final base = by[spec.base]!;
    if (overlay == null) {
      return copy(spec.name, base, 'Material default: `${base.name}`.');
    }
    final light = OverlayFit.blend(
      base.lightArgb,
      overlay.lightArgb,
      spec.opacity,
    );
    final dark = OverlayFit.blend(
      base.darkArgb,
      overlay.darkArgb,
      spec.opacity,
    );
    final percent = (spec.opacity * 100).round();
    return (
      name: spec.name,
      doc:
          'Material default: `${base.name}` with `${overlay.name}` at '
          '$percent%.',
      light: literal(light),
      dark: literal(dark),
      lightArgb: light,
      darkArgb: dark,
    );
  }

  static SchemeField _layer(StateSpec spec, SchemeField? overlay) {
    final alpha = (spec.opacity * 255).round() << 24;
    final light = overlay == null ? 0 : alpha | overlay.lightArgb & 0xFFFFFF;
    final dark = overlay == null ? 0 : alpha | overlay.darkArgb & 0xFFFFFF;
    final percent = (spec.opacity * 100).round();
    return (
      name: spec.name,
      doc: overlay == null
          ? 'Material default: transparent.'
          : 'Material default: `${overlay.name}` at $percent% on nothing.',
      light: literal(light),
      dark: literal(dark),
      lightArgb: light,
      darkArgb: dark,
    );
  }
}
