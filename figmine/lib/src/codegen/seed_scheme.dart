import 'dart:math' as math;

import 'package:figmine/src/codegen/seed_roles.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Derives ColorScheme roles from a seed color at generation time.
///
/// Uses the tonal spot scheme with standard contrast, the algorithm of
/// `ColorScheme.fromSeed`, but keeps a vivid seed's chroma in the primary
/// palette, so derived primary roles stay on the brand's own palette, as
/// in the Material 3 baseline. A gray seed, such
/// as the near black of a monochrome brand, uses the monochrome scheme, as
/// `DynamicSchemeVariant.monochrome` does, instead of inventing hues.
abstract final class SeedScheme {
  /// The Material 3 baseline seed, used when Figma has no seed.
  static const int baseline = 0xFF6750A4;

  /// Whether [seed] is too gray to carry a hue: perceptual chroma below 8.
  static bool isGray(int seed) => Hct.fromInt(seed).chroma < 8;

  /// Returns every ColorScheme role as ARGB for [seed], with the primary
  /// palette at least as vivid as [chroma], such as the light primary's.
  static Map<String, int> derive(
    int seed, {
    required bool dark,
    double chroma = 0,
  }) {
    final hct = Hct.fromInt(seed);
    final scheme = isGray(seed)
        ? SchemeMonochrome(sourceColorHct: hct, isDark: dark, contrastLevel: 0)
        : _vivid(hct, dark: dark, chroma: chroma);
    return {
      for (final entry in SeedRoles.colors.entries)
        entry.key: entry.value.getArgb(scheme),
    };
  }

  /// The tonal spot scheme with the primary palette at the seed's own
  /// chroma when it is above tonal spot's 36, as Material's original
  /// palettes and the Material 3 baseline keep a vivid brand vivid.
  static DynamicScheme _vivid(
    Hct hct, {
    required bool dark,
    required double chroma,
  }) {
    final spot = SchemeTonalSpot(
      sourceColorHct: hct,
      isDark: dark,
      contrastLevel: 0,
    );
    return DynamicScheme(
      sourceColorHct: hct,
      variant: spot.variant,
      isDark: dark,
      primaryPalette: TonalPalette.of(
        hct.hue,
        [hct.chroma, chroma, 36.0].reduce(math.max),
      ),
      secondaryPalette: spot.secondaryPalette,
      tertiaryPalette: spot.tertiaryPalette,
      neutralPalette: spot.neutralPalette,
      neutralVariantPalette: spot.neutralVariantPalette,
    );
  }
}
