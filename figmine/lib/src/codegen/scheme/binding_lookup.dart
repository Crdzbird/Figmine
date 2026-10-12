import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/inference/stats/paint_usage.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// Finds the token behind a role from screen bindings and token names.
abstract final class BindingLookup {
  static final Map<PaintUsage, RegExp> _fits = {
    PaintUsage.background: RegExp(r'fill|background|surface|\bbg\b|container'),
    PaintUsage.text: RegExp(r'text|foreground|content|\bon\b|on-'),
    PaintUsage.stroke: RegExp('border|stroke|outline|divider|line'),
  };

  /// The token the screens bind to [role] in [variables], among [all].
  ///
  /// Feedback tokens never stand in for brand roles. When another token of
  /// the same collection has the same color and a name that fits the role,
  /// such as `fills/...` for a background, that token wins. A token named
  /// for another use, such as `text/...` bound as a fill, is not used.
  static ColorCandidate? forRole(
    String role,
    Map<String, String> variables,
    List<ColorCandidate> all,
  ) {
    final id = variables[role];
    final match = all.where((c) => c.token.variableId == id).firstOrNull;
    if (id == null || match == null) return null;
    final brand =
        MaterialRoles.colorScheme.contains(role) &&
        !role.toLowerCase().contains('error');
    if (brand && ColorCandidates.isFeedback(match.token.name)) return null;
    final fit = _fits[PaintUsage.of(role)]!;
    if (fit.hasMatch(match.token.name.toLowerCase())) return match;
    final value = _argb(match);
    final better =
        all
            .where((c) => c.collection == match.collection && _argb(c) == value)
            .where((c) => fit.hasMatch(c.token.name.toLowerCase()))
            .toList()
          ..sort((a, b) => rank(a, match) - rank(b, match));
    final other = _fits.entries
        .where((e) => e.key != PaintUsage.of(role))
        .any((e) => e.value.hasMatch(match.token.name.toLowerCase()));
    return better.firstOrNull ?? (other ? null : match);
  }

  static final RegExp _state = RegExp(
    'inverse|hover|pressed|disabled|focus|selected|visited|negative',
  );

  /// Orders candidate tokens, lower is better: no state variant, most
  /// segments shared with [reference] beyond the first, then the shortest
  /// path.
  static int rank(ColorCandidate c, ColorCandidate? reference) {
    final name = c.token.name.toLowerCase();
    final shared = reference == null
        ? 0
        : c.token.path.skip(1).where(reference.token.path.contains).length;
    return (_state.hasMatch(name) ? 100 : 0) -
        shared * 10 +
        c.token.path.length;
  }

  static int? _argb(ColorCandidate candidate) {
    final value = candidate.token.values.values.first.value;
    return value is ColorValue ? value.argb : null;
  }
}
