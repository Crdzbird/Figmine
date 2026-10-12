import 'package:figmine/src/codegen/derive/derived_roles.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/codegen/scheme/role_ramp.dart';
import 'package:figmine/src/codegen/scheme/role_ramps.dart';
import 'package:figmine/src/codegen/scheme/step_assignment.dart';
import 'package:figmine/src/codegen/scheme/step_reference.dart';
import 'package:figmine/src/config/tokens_config.dart';

export 'package:figmine/src/codegen/scheme/step_reference.dart'
    show DerivedValue;

/// Roles whose light or dark value comes from elsewhere than derivation.
typedef FixedRoles = ({Set<String> light, Set<String> dark});

/// Values for roles Figma lacks: derived from the seed, then moved onto a
/// step of the design's own role scale when one is close in tone.
final class DerivedValues {
  /// Creates values from [derived], snapping to [ramps].
  factory(
    DerivedRoles derived,
    Map<String, RoleRamp> ramps,
    TokenIndex index,
    TokensConfig tokens, {
    FixedRoles fixed,
  }) = DerivedValues._;

  new _(
    this.derived,
    this.ramps,
    this.index,
    this.tokens, {
    this.fixed = (light: const {}, dark: const {}),
  });

  /// The roles derived from the seed.
  final DerivedRoles derived;

  /// The role scales of the design, by family.
  final Map<String, RoleRamp> ramps;

  /// Generated addresses of the tokens.
  final TokenIndex index;

  /// Token settings, for the light and dark mode names.
  final TokensConfig tokens;

  /// Roles whose value in a mode is not derived, which take no step.
  final FixedRoles fixed;

  late final Map<String, Map<int, ColorCandidate>> _light =
      StepAssignment.assign(derived.light, ramps, skip: fixed.light);

  late final Map<String, Map<int, ColorCandidate>> _dark =
      StepAssignment.assign(derived.dark, ramps, skip: fixed.dark);

  /// Whether [role] can be derived.
  bool has(String role) => derived.light.containsKey(role);

  /// The derived value of [role] in light or [dark] mode, on the step
  /// assigned to it, if any.
  DerivedValue of(String role, {required bool dark}) {
    final argb = (dark ? derived.dark : derived.light)[role]!;
    final family = RoleRamps.familyOf(role);
    return _value(role, argb, (dark ? _dark : _light)[family]?[argb]);
  }

  /// The step of the scale of [role] closest in tone to [argb].
  DerivedValue near(String role, int argb) =>
      _value(role, argb, _ramp(role)?.nearest(argb));

  RoleRamp? _ramp(String role) => ramps[RoleRamps.familyOf(role)];

  DerivedValue _value(String role, int argb, ColorCandidate? step) =>
      StepReference.value(argb, step, _ramp(role), index, tokens);
}
