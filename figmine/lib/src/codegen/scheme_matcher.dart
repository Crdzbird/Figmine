import 'package:figmine/src/codegen/binding_lookup.dart';
import 'package:figmine/src/codegen/color_candidates.dart';
import 'package:figmine/src/codegen/feedback_lookup.dart';
import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/codegen/role_ramp.dart';
import 'package:figmine/src/codegen/role_ramps.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/inference/screen_evidence.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';

export 'package:figmine/src/codegen/color_candidates.dart' show ColorCandidate;

/// Finds the tokens behind ColorScheme roles, extra fields and the seed.
final class SchemeMatcher {
  /// Creates a matcher over the color tokens of [collections].
  factory(
    List<TokenCollection> collections,
    SchemeConfig config, {
    ScreenEvidence evidence,
  }) = SchemeMatcher._;

  new _(
    List<TokenCollection> collections,
    this.config, {
    this.evidence = noEvidence,
  }) : all = [
         for (final collection in collections)
           for (final token in collection.tokens)
             if (token.type == TokenType.color)
               (collection: collection, token: token),
       ];

  /// Scheme settings.
  final SchemeConfig config;

  /// What the screens tell about colors.
  final ScreenEvidence evidence;

  /// Every color token.
  final List<ColorCandidate> all;

  /// The role scales of the design, by family.
  late final Map<String, RoleRamp> ramps = RoleRamps.find(all);

  /// Tokens of `color_scheme.collection`, or every color token.
  List<ColorCandidate> get scoped => config.collection == null
      ? all
      : all.where((c) => c.collection.name == config.collection).toList();

  /// Returns the token of each Material role found in Figma: configured,
  /// named after the role, or bound to the role's color in the screens.
  /// A role scale, such as `tertiary/10` to `tertiary/100`, overrules a
  /// binding off the scale. Error comes from the feedback lookup, which
  /// knows aliases such as `danger`.
  Map<String, ColorCandidate> roles() {
    for (final role in config.roles.keys) {
      if (MaterialRoles.colorScheme.contains(role)) continue;
      throw ConfigException('Unknown ColorScheme role `$role`.');
    }
    final found = {
      for (final role in MaterialRoles.colorScheme)
        role: ?(config.roles[role] == null
            ? _find(role)
            : lookup(config.roles[role]!)),
    };
    return {
      ...found,
      if (!found.containsKey('error'))
        'error': ?FeedbackLookup.forScheme('error', this, found),
    };
  }

  ColorCandidate? _find(String role) {
    if (role == 'error') return ColorCandidates.byLeaf(scoped, role);
    final bound = BindingLookup.forRole(role, evidence.roleVariables, all);
    return ColorCandidates.byLeaf(scoped, role) ??
        (ramps[role]?.prefer(bound, evidence.colorUses) ?? bound);
  }

  /// The seed token: configured, named `seed`, or the primary role.
  ColorCandidate? seed(Map<String, ColorCandidate> roles) {
    final configured = config.seed;
    if (configured != null) return lookup(configured);
    return ColorCandidates.byLeaf(all, 'seed') ?? roles['primary'];
  }

  /// Finds the token called [name], preferring the scheme collection.
  ColorCandidate lookup(String name) {
    for (final candidate in [...scoped, ...all]) {
      if (candidate.token.name == name) return candidate;
    }
    throw ConfigException('Color token `$name` was not found in Figma.');
  }
}
