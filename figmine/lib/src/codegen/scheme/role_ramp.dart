import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// A numbered color scale named after a scheme role, such as `tertiary/10`
/// to `tertiary/100`.
final class RoleRamp {
  /// Creates a scale of [steps] for the role [family].
  const factory({required String family, required List<ColorCandidate> steps}) =
      RoleRamp._;

  const new _({required this.family, required this.steps});

  /// The role the scale belongs to, such as `tertiary`.
  final String family;

  /// The steps, in scale order.
  final List<ColorCandidate> steps;

  /// The color of [step].
  static int argb(ColorCandidate step) {
    final value = step.token.values.values.first.value;
    return value is ColorValue ? value.argb : 0;
  }

  /// Whether one of the steps has the color [color].
  bool contains(int color) => steps.any((s) => argb(s) == color);

  /// The step that stands for the role: among the most colorful steps, the
  /// one the screens use most according to [uses], then the most colorful.
  ColorCandidate key(Map<int, int> uses) {
    double chroma(ColorCandidate s) => ColorMath.chroma(argb(s));
    final most = steps.map(chroma).reduce((a, b) => a > b ? a : b);
    final vivid = steps.where((s) => chroma(s) >= most * 0.85).toList()
      ..sort((a, b) {
        final used = (uses[argb(b)] ?? 0) - (uses[argb(a)] ?? 0);
        return used != 0 ? used : chroma(b).compareTo(chroma(a));
      });
    return vivid.first;
  }

  /// The token for the key role: [bound] when its color is on the scale,
  /// otherwise the [key] step.
  ColorCandidate prefer(ColorCandidate? bound, Map<int, int> uses) {
    if (bound != null && contains(argb(bound))) return bound;
    return key(uses);
  }

  /// The token for a feedback role, which must read as text on [surface]:
  /// [bound] when on the scale and readable, otherwise the readable step
  /// the screens use most, then the lightest readable step, then [key].
  ColorCandidate readable(
    ColorCandidate? bound,
    Map<int, int> uses,
    int surface,
  ) {
    bool reads(ColorCandidate s) => ColorMath.contrast(argb(s), surface) >= 4.5;
    if (bound != null && contains(argb(bound)) && reads(bound)) return bound;
    final passing = steps.where(reads).toList()
      ..sort((a, b) {
        final used = (uses[argb(b)] ?? 0) - (uses[argb(a)] ?? 0);
        if (used != 0) return used;
        return ColorMath.contrast(
          argb(a),
          surface,
        ).compareTo(ColorMath.contrast(argb(b), surface));
      });
    return passing.firstOrNull ?? key(uses);
  }

  /// The hue and chroma of the most colorful step at [tone]. Scales of
  /// grays give pure grays.
  int at(double tone) {
    final vivid = steps
        .map((s) => Hct.fromInt(argb(s)))
        .reduce((a, b) => b.chroma > a.chroma ? b : a);
    final chroma = vivid.chroma < 4 ? 0.0 : vivid.chroma;
    return Hct.from(vivid.hue, chroma, tone).toInt();
  }

  /// The step closest in tone to [color], when no further than [tolerance]
  /// on the 0 to 100 tone scale.
  ColorCandidate? nearest(int color, {double tolerance = 6}) {
    final tone = Hct.fromInt(color).tone;
    double distance(ColorCandidate s) =>
        (Hct.fromInt(argb(s)).tone - tone).abs();
    final best = steps.reduce((a, b) => distance(b) < distance(a) ? b : a);
    return distance(best) <= tolerance ? best : null;
  }
}
