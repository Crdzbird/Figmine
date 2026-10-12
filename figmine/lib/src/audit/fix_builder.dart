import 'package:figmine/src/audit/contrast_finding.dart';
import 'package:figmine/src/audit/contrast_fix.dart';
import 'package:figmine/src/audit/fix_candidates.dart';
import 'package:figmine/src/audit/tone_fix.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/inference/color/color_math.dart';

/// Builds contrast fixes for single failing pairs.
abstract final class FixBuilder {
  /// The fix of [f] with [token], measured in the mode of [f].
  static ContrastFix? token(
    ContrastFinding f,
    FixCandidate? token,
    Map<String, SchemeField> by,
  ) {
    final background = by[f.background];
    if (token == null || background == null) return null;
    final color = f.mode == 'dark' ? token.dark : token.light;
    bool passes(int fg, int bg) => ColorMath.contrast(fg, bg) >= f.required;
    return (
      field: f.foreground,
      argb: color,
      ratio: ColorMath.contrast(color, f.backgroundArgb),
      token: token.name,
      collection: token.collection,
      bothModes:
          passes(token.light, background.lightArgb) &&
          passes(token.dark, background.darkArgb),
    );
  }

  /// The fix of [f] with its foreground moved in tone.
  static ContrastFix? tone(ContrastFinding f) {
    final color = ToneFix.nearest(
      f.foregroundArgb,
      f.backgroundArgb,
      f.required,
    );
    if (color == null) return null;
    return (
      field: f.foreground,
      argb: color,
      ratio: ColorMath.contrast(color, f.backgroundArgb),
      token: null,
      collection: null,
      bothModes: false,
    );
  }
}
