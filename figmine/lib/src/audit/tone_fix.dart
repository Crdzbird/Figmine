import 'package:figmine/src/inference/color_math.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Moves a color in tone until it contrasts enough with a background.
abstract final class ToneFix {
  /// [color] with its hue and chroma at the tone closest to its own that
  /// reaches [ratio] against [background], or null when none does.
  static int? nearest(int color, int background, double ratio) {
    final hct = Hct.fromInt(color);
    final darker = ColorMath.luminance(background) > 0.18;
    for (var step = 1; step <= 100; step++) {
      final tone = hct.tone + (darker ? -step : step);
      if (tone < 0 || tone > 100) return null;
      final moved = Hct.from(hct.hue, hct.chroma, tone).toInt();
      if (ColorMath.contrast(moved, background) >= ratio) return moved;
    }
    return null;
  }
}
