import 'package:figmine/src/codegen/derive/derived_fields.dart';
import 'package:figmine/src/codegen/derive/derived_values.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/emit/value_expressions.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// A field of the generated color scheme with its light and dark values.
typedef SchemeField = ({
  String name,
  String doc,
  ValueExpression light,
  ValueExpression dark,
  int lightArgb,
  int darkArgb,
});

/// Builds single scheme fields.
abstract final class SchemeFieldBuilders {
  /// White or black text, whichever reads better on [background].
  static SchemeField readable(String name, SchemeField background) {
    final light = ColorMath.readableOn(background.lightArgb);
    final dark = ColorMath.readableOn(background.darkArgb);
    return (
      name: name,
      doc: 'Readable text on `${background.name}`.',
      light: (
        code: DartSource.color(ColorValue.fromArgb(light).hex),
        file: null,
      ),
      dark: (code: DartSource.color(ColorValue.fromArgb(dark).hex), file: null),
      lightArgb: light,
      darkArgb: dark,
    );
  }

  /// A field that references the generated constants of [candidate].
  ///
  /// When its collection has no dark mode, the dark value of a Material
  /// role comes from [derived] instead of repeating the light one.
  static SchemeField field(
    String name,
    ColorCandidate candidate,
    TokenIndex index,
    TokensConfig tokens, {
    DerivedValues? derived,
  }) {
    final modes = CollectionModes.pick(candidate.collection.modes, tokens);
    final dark = modes.light == modes.dark && (derived?.has(name) ?? false)
        ? derived!.of(name, dark: true)
        : null;
    ValueExpression at(String mode) {
      final address = index.find(
        candidate.collection.name,
        candidate.token.name,
        mode,
      )!;
      return (
        code: '${address.className}.${address.member}',
        file: address.file,
      );
    }

    final source =
        'Figma `${candidate.token.name}` in `${candidate.collection.name}`.';
    final note = dark == null
        ? ''
        : ' The dark value is derived.${DerivedFields.steps(null, dark)}';
    return (
      name: name,
      doc: '$source$note',
      light: at(modes.light),
      dark: dark?.value ?? at(modes.dark),
      lightArgb: _argb(candidate, modes.light),
      darkArgb: dark?.argb ?? _argb(candidate, modes.dark),
    );
  }

  static int _argb(ColorCandidate candidate, String mode) {
    final value = candidate.token.values[mode]?.value;
    return value is ColorValue ? value.argb : 0;
  }
}
