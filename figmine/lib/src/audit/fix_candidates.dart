import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// A color token that could replace a failing foreground.
typedef FixCandidate = ({String collection, String name, int light, int dark});

/// Lists replacement colors and measures how far they are from a color.
abstract final class FixCandidates {
  /// Every color token of [collections] with its light and dark value.
  static List<FixCandidate> of(
    List<TokenCollection> collections,
    TokensConfig config,
  ) => [
    for (final c in collections)
      if (CollectionModes.pick(c.modes, config) case final modes)
        for (final t in c.tokens)
          if (t.values[modes.light]?.value case final ColorValue light)
            (
              collection: c.name,
              name: t.name,
              light: light.argb,
              dark: switch (t.values[modes.dark]?.value) {
                final ColorValue dark => dark.argb,
                _ => light.argb,
              },
            ),
  ];

  /// Perceptual distance between [a] and [b]: tone, chroma and, when both
  /// are colorful, hue.
  static double distance(int a, int b) {
    final x = Hct.fromInt(a);
    final y = Hct.fromInt(b);
    final hue = (x.hue - y.hue).abs() % 360;
    final turn = hue > 180 ? 360 - hue : hue;
    final colorful = x.chroma > 8 && y.chroma > 8;
    return (x.tone - y.tone).abs() +
        (x.chroma - y.chroma).abs() / 2 +
        (colorful ? turn / 3 : 0);
  }
}
