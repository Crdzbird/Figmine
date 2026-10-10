import 'package:figmine/src/codegen/derived_fields.dart';
import 'package:figmine/src/codegen/derived_values.dart';
import 'package:figmine/src/codegen/override_fields.dart';
import 'package:figmine/src/codegen/role_pairs.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/color_overrides.dart';
import 'package:figmine/src/config/tokens_config.dart';

/// Builds the field of each Material role, in role order.
final class SchemeRoleBuilder {
  /// Creates a builder over the [roles] found in Figma.
  const factory({
    required Map<String, ColorCandidate> roles,
    required Set<String> readable,
    required Map<String, ColorOverride> overrides,
    required DerivedValues values,
    required TokenIndex index,
    required TokensConfig tokens,
  }) = SchemeRoleBuilder._;

  const new _({
    required this.roles,
    required this.readable,
    required this.overrides,
    required this.values,
    required this.index,
    required this.tokens,
  });

  /// Roles found in Figma.
  final Map<String, ColorCandidate> roles;

  /// `on` roles that need a color readable on their background.
  final Set<String> readable;

  /// Colors set by hand.
  final Map<String, ColorOverride> overrides;

  /// Values for roles Figma lacks.
  final DerivedValues values;

  /// Generated addresses of the tokens.
  final TokenIndex index;

  /// Token settings.
  final TokensConfig tokens;

  /// The field of [role] named [name], given the fields [built] so far:
  /// set by hand, readable on its background, found in Figma, the same as
  /// primary for `surfaceTint`, or derived.
  SchemeField build(String role, String name, Map<String, SchemeField> built) {
    final color = overrides[role];
    if (color != null) {
      final derive = color.dark == null && values.has(role);
      return OverrideFields.of(
        name,
        color,
        derived: derive
            ? DerivedFields.dark(role, color.light.argb, values)
            : null,
      );
    }
    final base = RolePairs.base(role);
    if (readable.contains(role) && base != null) {
      return SchemeFieldBuilders.readable(name, built[base]!);
    }
    final candidate = roles[role];
    if (candidate != null) {
      return SchemeFieldBuilders.field(
        name,
        candidate,
        index,
        tokens,
        derived: values,
      );
    }
    final primary = built['primary'];
    if (role == 'surfaceTint' && primary != null) {
      return (
        name: name,
        doc: 'Same as `primary`.',
        light: primary.light,
        dark: primary.dark,
        lightArgb: primary.lightArgb,
        darkArgb: primary.darkArgb,
      );
    }
    return DerivedFields.role(name, role, values);
  }
}
