import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/derived_fields.dart';
import 'package:figmine/src/codegen/derived_values.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/config/color_overrides.dart';

/// Builds scheme fields set by hand.
abstract final class OverrideFields {
  /// A field set by hand in `color_scheme.overrides`. Without a dark
  /// color, [derived] gives the dark value, or the light one repeats.
  static SchemeField of(
    String name,
    ColorOverride color, {
    DerivedValue? derived,
  }) {
    final dark = color.dark ?? color.light;
    return (
      name: name,
      doc:
          'Set by hand in figmine.yaml, color_scheme.overrides.'
          '${derived == null ? '' : ' The dark value is derived.'}'
          '${derived == null ? '' : DerivedFields.steps(null, derived)}',
      light: (code: DartSource.color(color.light.hex), file: null),
      dark: derived?.value ?? (code: DartSource.color(dark.hex), file: null),
      lightArgb: color.light.argb,
      darkArgb: derived?.argb ?? dark.argb,
    );
  }
}
