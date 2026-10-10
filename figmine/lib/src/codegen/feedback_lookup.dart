import 'package:figmine/src/codegen/binding_lookup.dart';
import 'package:figmine/src/codegen/color_candidates.dart';
import 'package:figmine/src/codegen/feedback_hues.dart';
import 'package:figmine/src/codegen/role_ramp.dart';
import 'package:figmine/src/codegen/role_ramps.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/inference/color_math.dart';

/// Finds the token of a feedback role, such as `success`, which serves as
/// text and icon color on the surface the way `error` does.
abstract final class FeedbackLookup {
  static final List<RegExp> _foreground = [
    RegExp('text|foreground|content'),
    RegExp('icon'),
    RegExp('border|stroke'),
  ];

  /// [find] for the scheme of [matcher], given the Material [roles] found
  /// so far: read on their surface, away from their primary and secondary.
  static ColorCandidate? forScheme(
    String name,
    SchemeMatcher matcher,
    Map<String, ColorCandidate> roles,
  ) {
    int? argb(String role) {
      final c = roles[role];
      return c == null ? null : RoleRamp.argb(c);
    }

    return find(
      name,
      variables: matcher.evidence.roleVariables,
      all: matcher.all,
      ramp: matcher.ramps[name],
      uses: matcher.evidence.colorUses,
      surface: argb('surface') ?? ColorMath.white,
      brand: [?argb('primary'), ?argb('secondary')],
    );
  }

  /// The token for [name]: the token named exactly after it, otherwise the
  /// token bound in the screens or named after the role or one of its
  /// aliases, such as `positive` for `success`, that reads as text on
  /// [surface] and does not
  /// share a hue with the [brand] colors, with a hue that fits the role,
  /// such as green for success. Text tokens come first, then icon and
  /// border tokens, then other tokens. Without any, the readable step of
  /// the role [ramp].
  static ColorCandidate? find(
    String name, {
    required Map<String, String> variables,
    required List<ColorCandidate> all,
    required RoleRamp? ramp,
    required Map<int, int> uses,
    required int surface,
    required List<int> brand,
  }) {
    final named = ColorCandidates.byLeaf(all, name);
    if (named != null) return named;
    final bound = BindingLookup.forRole(name, variables, all);
    bool fits(ColorCandidate c) {
      final argb = RoleRamp.argb(c);
      return ColorMath.contrast(argb, surface) >= 4.5 &&
          FeedbackHues.fits(name, argb) &&
          !brand.any(
            (b) =>
                ColorMath.chroma(b) >= 0.1 &&
                ColorMath.hueDistance(argb, b) < 15 &&
                ColorMath.chroma(argb) >= 0.1,
          );
    }

    if (bound != null && fits(bound)) return bound;
    int foreground(ColorCandidate c) {
      final rank = _foreground.indexWhere(
        (r) => r.hasMatch(c.token.name.toLowerCase()),
      );
      return rank < 0 ? _foreground.length : rank;
    }

    final aliases = (RoleRamps.families[name] ?? [name]).join('|');
    final words = RegExp('(^|[^a-z])($aliases)([^a-z]|\$)');
    final matches =
        all
            .where((c) => words.hasMatch(c.token.name.toLowerCase()))
            .where(fits)
            .toList()
          ..sort((a, b) {
            final fit = foreground(a) - foreground(b);
            if (fit != 0) return fit;
            return BindingLookup.rank(a, null) - BindingLookup.rank(b, null);
          });
    return matches.firstOrNull ?? ramp?.readable(bound, uses, surface);
  }
}
