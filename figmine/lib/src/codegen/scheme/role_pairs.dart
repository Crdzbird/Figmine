import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/codegen/scheme/role_ramp.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/inference/color/color_math.dart';

/// Keeps foreground roles consistent with their backgrounds.
abstract final class RolePairs {
  /// The background of an `on` role, such as `primary` for `onPrimary`.
  static String? base(String role) {
    if (!role.startsWith('on') || role.length < 3) return null;
    final base = '${role[2].toLowerCase()}${role.substring(3)}';
    return MaterialRoles.colorScheme.contains(base) ? base : null;
  }

  /// Drops `on` roles whose background does not come from Figma: text
  /// picked for a Figma background says nothing about a derived one.
  ///
  /// Backgrounds set by hand in [manual] never keep a Figma foreground, and
  /// neither do backgrounds the foreground does not read on, such as a
  /// variable the screens show in another mode.
  static Map<String, ColorCandidate> consistent(
    Map<String, ColorCandidate> roles, [
    Set<String> manual = const {},
  ]) => {
    for (final entry in roles.entries)
      if (base(entry.key) case final b
          when b == null ||
              (roles.containsKey(b) &&
                  !manual.contains(b) &&
                  _reads(entry.value, roles[b]!)))
        entry.key: entry.value,
  };

  static bool _reads(ColorCandidate text, ColorCandidate background) =>
      ColorMath.contrast(RoleRamp.argb(text), RoleRamp.argb(background)) >= 3;

  /// `on` roles whose background comes from Figma but which do not, and so
  /// need a color readable on that background.
  static Set<String> readable(
    Map<String, ColorCandidate> roles, [
    Set<String> manual = const {},
  ]) => {
    for (final role in MaterialRoles.colorScheme)
      if (base(role) case final b?)
        if ((roles.containsKey(b) || manual.contains(b)) &&
            !roles.containsKey(role) &&
            !manual.contains(role))
          role,
  };
}
