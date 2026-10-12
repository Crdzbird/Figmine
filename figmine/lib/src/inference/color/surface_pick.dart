import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Picks the surface among the neutral backgrounds.
abstract final class SurfacePick {
  /// Whether [c] is drawn on the frames' own fill, [board], as a surface:
  /// lighter than a light board, or darker than a dark one, on 5% of the
  /// area across three screens, such as app screens on a documentation page.
  static bool _onBoard(int c, int? board, UsageStats s) {
    if (board == null || c == board) return false;
    final light = ColorMath.luminance(board) >= 0.2;
    final away = light
        ? ColorMath.luminance(c) > ColorMath.luminance(board)
        : ColorMath.luminance(c) < ColorMath.luminance(board);
    return away &&
        s.backgroundArea[c]! >= s.totalArea * 0.05 &&
        (s.colorFrames[c]?.length ?? 0) >= 3;
  }

  /// The lightest neutral background covering a fifth of the area, or the
  /// darkest when the largest one is dark: the base the others sit on.
  static int? of(List<int> neutral, UsageStats s) {
    final board = UsageStats.ranked(s.frameFills).firstOrNull;
    final major = neutral
        .where(
          (c) =>
              s.backgroundArea[c]! >= s.totalArea * 0.2 ||
              _onBoard(c, board, s),
        )
        .toList();
    if (major.isEmpty) return neutral.firstOrNull;
    final dark = ColorMath.luminance(major.first) < 0.2;
    return major.reduce((a, b) {
      final lighter = ColorMath.luminance(b) > ColorMath.luminance(a);
      return lighter != dark ? b : a;
    });
  }
}
