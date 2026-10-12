import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/emit/value_expressions.dart';
import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/codegen/scheme/role_ramp.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// A scheme value, with a note on where it comes from when it is not the
/// plain derived color, such as the Figma token of a scale step.
typedef DerivedValue = ({ValueExpression value, int argb, String? note});

/// Turns derived colors into references to scale steps.
abstract final class StepReference {
  /// [step] of [ramp] as a reference to its generated constant. Without a
  /// step, the tone of [argb] in the hue of [ramp], or [argb] itself when
  /// there is no scale.
  static DerivedValue value(
    int argb,
    ColorCandidate? step,
    RoleRamp? ramp,
    TokenIndex index,
    TokensConfig tokens,
  ) {
    final address = step == null
        ? null
        : index.find(
            step.collection.name,
            step.token.name,
            CollectionModes.pick(step.collection.modes, tokens).light,
          );
    if (step == null || address == null) {
      final hued = ramp?.at(Hct.fromInt(argb).tone) ?? argb;
      final hex = ColorValue.fromArgb(hued).hex;
      return (
        value: (code: DartSource.color(hex), file: null),
        argb: hued,
        note: ramp == null ? null : 'the hue of the `${ramp.family}` scale',
      );
    }
    return (
      value: (
        code: '${address.className}.${address.member}',
        file: address.file,
      ),
      argb: RoleRamp.argb(step),
      note: 'Figma `${step.token.name}`',
    );
  }
}
