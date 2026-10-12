import 'package:figmine/src/codegen/derive/derived_fields.dart';
import 'package:figmine/src/codegen/derive/derived_roles.dart';
import 'package:figmine/src/codegen/derive/derived_values.dart';
import 'package:figmine/src/codegen/derive/fixed_role_sets.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/codegen/scheme/override_fields.dart';
import 'package:figmine/src/codegen/scheme/role_pairs.dart';
import 'package:figmine/src/codegen/scheme/scheme_extras.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/codegen/scheme/scheme_role_builder.dart';
import 'package:figmine/src/codegen/states/state_fields.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color/feedback_roles.dart';
import 'package:figmine/src/naming/unique_namer.dart';

export 'package:figmine/src/codegen/scheme/scheme_field_builders.dart'
    show SchemeField;

/// Builds the fields of the generated color scheme.
abstract final class SchemeFields {
  /// Names the scheme class uses for its own members.
  static final Set<String> reserved =
      'brightness light dark copyWith lerp '
              'toColorScheme type hashCode runtimeType toString'
          .split(' ')
          .toSet();

  /// Every Material role, matched or derived, followed by extra fields and
  /// the component state fields.
  static List<SchemeField> resolve({
    required SchemeMatcher matcher,
    required TokenIndex index,
    required TokensConfig tokens,
  }) {
    final overrides = matcher.config.overrides;
    final roles = RolePairs.consistent(matcher.roles(), overrides.keys.toSet());
    final readable = RolePairs.readable(roles, overrides.keys.toSet());
    final built = <String, SchemeField>{};
    final values = DerivedValues(
      DerivedRoles(matcher.seed(roles), tokens),
      matcher.ramps,
      index,
      tokens,
      fixed: FixedRoleSets.of(roles, readable, overrides, tokens),
    );
    final names = UniqueNamer();
    reserved.forEach(names.claim);
    final builder = SchemeRoleBuilder(
      roles: roles,
      readable: readable,
      overrides: overrides,
      values: values,
      index: index,
      tokens: tokens,
    );
    for (final role in MaterialRoles.colorScheme) {
      built[role] = builder.build(role, names.claim(role), built);
    }
    final extras = SchemeExtras.of(matcher, roles);
    SchemeField extraField(MapEntry<String, ColorCandidate> entry) {
      final name = names.claim(entry.key);
      final color = overrides[entry.key];
      if (color != null) return OverrideFields.of(name, color);
      return SchemeFieldBuilders.field(name, entry.value, index, tokens);
    }

    final extra = extras.entries.map(extraField).toList();
    String on(String name) => 'on${name[0].toUpperCase()}${name.substring(1)}';
    final fields = [
      ...built.values,
      ...extra,
      for (final field in extra)
        if (FeedbackRoles.names.contains(field.name) &&
            !extras.containsKey(on(field.name)) &&
            !overrides.containsKey(on(field.name)))
          SchemeFieldBuilders.readable(names.claim(on(field.name)), field),
      for (final field in extra)
        if (FeedbackRoles.names.contains(field.name))
          ...DerivedFields.containers(
            field.name,
            values,
            (role) => extras.containsKey(role) || overrides.containsKey(role),
          ),
      for (final entry in overrides.entries)
        if (!MaterialRoles.colorScheme.contains(entry.key) &&
            !extras.containsKey(entry.key))
          OverrideFields.of(names.claim(entry.key), entry.value),
    ];
    return [...fields, ...StateFields.resolve(fields, matcher, index, tokens)];
  }
}
