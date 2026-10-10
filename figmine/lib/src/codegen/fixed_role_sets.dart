import 'package:figmine/src/codegen/derived_values.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/config/color_overrides.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/collection_modes.dart';

/// Tells which roles get their light or dark value from somewhere other
/// than derivation.
abstract final class FixedRoleSets {
  /// Roles found in Figma, made readable, set by hand or copied from
  /// primary. In dark mode, roles found in a collection without a dark
  /// mode are still derived.
  static FixedRoles of(
    Map<String, ColorCandidate> roles,
    Set<String> readable,
    Map<String, ColorOverride> overrides,
    TokensConfig tokens,
  ) {
    final always = {...readable, 'surfaceTint'};
    return (
      light: {...always, ...roles.keys, ...overrides.keys},
      dark: {
        ...always,
        for (final entry in roles.entries)
          if (_hasDark(entry.value, tokens)) entry.key,
        ...overrides.keys,
      },
    );
  }

  static bool _hasDark(ColorCandidate candidate, TokensConfig tokens) {
    final modes = CollectionModes.pick(candidate.collection.modes, tokens);
    return modes.light != modes.dark;
  }
}
