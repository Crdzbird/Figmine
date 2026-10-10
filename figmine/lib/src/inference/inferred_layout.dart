import 'package:figmine/src/inference/scale_inferrer.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Turns spacing and radius usage into a token collection.
abstract final class InferredLayout {
  /// Name of the inferred spacing and radius collection.
  static const String layoutName = 'Inferred layout';

  /// Spacing and radius scales of [stats], or null when empty.
  static TokenCollection? collection(List<UsageStats> stats) {
    final spacing = <int, int>{};
    final radii = <int, int>{};
    var pills = 0;
    for (final s in stats) {
      s.spacing.forEach((k, v) => UsageStats.count(spacing, k, v));
      s.radii.forEach((k, v) => UsageStats.count(radii, k, v));
      pills += s.pills;
    }
    final tokens = [
      for (final v in ScaleInferrer.scale(spacing))
        _number(
          ['spacing', '$v'],
          v,
          'Used ${spacing[v]} times in auto layout.',
        ),
      for (final v in ScaleInferrer.scale(radii))
        _number(
          ['radius', '$v'],
          v,
          'Used ${radii[v]} times as corner radius.',
        ),
      if (pills > 1)
        _number(['radius', 'full'], 999, 'Fully rounded, used $pills times.'),
    ];
    if (tokens.isEmpty) return null;
    return TokenCollection(
      name: layoutName,
      modes: const ['Value'],
      tokens: tokens,
    );
  }

  static DesignToken _number(List<String> path, int value, String doc) =>
      DesignToken(
        path: path,
        type: TokenType.number,
        description: 'Inferred from the screens. $doc',
        values: {'Value': TokenValue(value.toDouble())},
      );
}
