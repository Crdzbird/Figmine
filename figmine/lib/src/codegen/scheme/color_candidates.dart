import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// A color token with the collection it belongs to.
typedef ColorCandidate = ({TokenCollection collection, DesignToken token});

/// Searches color candidates.
abstract final class ColorCandidates {
  static final RegExp _feedback = RegExp(
    'error|warning|success|info|feedback|danger|alert',
  );

  /// Whether the token called [name] is a feedback color, such as a
  /// warning, which must not stand in for a brand role.
  static bool isFeedback(String name) => _feedback.hasMatch(name.toLowerCase());

  static final RegExp _usage = RegExp(
    '(^|[/_ -])(fills?|backgrounds?|bg|borders?|strokes?|outlines?|texts?|'
    r'icons?|foregrounds?)($|[/_ -])',
  );

  /// The token whose last segment names [role], with the shortest path.
  /// Tokens in usage groups, such as `border/feedback/success`, do not
  /// count: they name where a color goes, not which role it is.
  static ColorCandidate? byLeaf(List<ColorCandidate> pool, String role) {
    ColorCandidate? best;
    for (final candidate in pool) {
      if (DartIdentifier.camel([candidate.token.leaf]) != role) continue;
      final groups = candidate.token.path.take(candidate.token.path.length - 1);
      if (_usage.hasMatch(groups.join('/').toLowerCase())) continue;
      final length = candidate.token.path.length;
      if (best == null || length < best.token.path.length) best = candidate;
    }
    return best;
  }
}
