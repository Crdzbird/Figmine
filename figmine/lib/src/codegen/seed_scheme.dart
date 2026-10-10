import 'package:material_color_utilities/material_color_utilities.dart';

/// Derives ColorScheme roles from a seed color at generation time.
///
/// Uses the tonal spot scheme with standard contrast, the same algorithm as
/// `ColorScheme.fromSeed`, so derived roles match Flutter. A gray seed, such
/// as the near black of a monochrome brand, uses the monochrome scheme, as
/// `DynamicSchemeVariant.monochrome` does, instead of inventing hues.
abstract final class SeedScheme {
  /// The Material 3 baseline seed, used when Figma has no seed.
  static const int baseline = 0xFF6750A4;

  /// Whether [seed] is too gray to carry a hue: perceptual chroma below 8.
  static bool isGray(int seed) => Hct.fromInt(seed).chroma < 8;

  /// Returns every ColorScheme role as ARGB for [seed].
  static Map<String, int> derive(int seed, {required bool dark}) {
    final hct = Hct.fromInt(seed);
    final scheme = isGray(seed)
        ? SchemeMonochrome(sourceColorHct: hct, isDark: dark, contrastLevel: 0)
        : SchemeTonalSpot(sourceColorHct: hct, isDark: dark, contrastLevel: 0);
    return {
      for (final entry in _colors.entries)
        entry.key: entry.value.getArgb(scheme),
    };
  }

  static final Map<String, DynamicColor> _colors = {
    'primary': MaterialDynamicColors.primary,
    'onPrimary': MaterialDynamicColors.onPrimary,
    'primaryContainer': MaterialDynamicColors.primaryContainer,
    'onPrimaryContainer': MaterialDynamicColors.onPrimaryContainer,
    'primaryFixed': MaterialDynamicColors.primaryFixed,
    'primaryFixedDim': MaterialDynamicColors.primaryFixedDim,
    'onPrimaryFixed': MaterialDynamicColors.onPrimaryFixed,
    'onPrimaryFixedVariant': MaterialDynamicColors.onPrimaryFixedVariant,
    'secondary': MaterialDynamicColors.secondary,
    'onSecondary': MaterialDynamicColors.onSecondary,
    'secondaryContainer': MaterialDynamicColors.secondaryContainer,
    'onSecondaryContainer': MaterialDynamicColors.onSecondaryContainer,
    'secondaryFixed': MaterialDynamicColors.secondaryFixed,
    'secondaryFixedDim': MaterialDynamicColors.secondaryFixedDim,
    'onSecondaryFixed': MaterialDynamicColors.onSecondaryFixed,
    'onSecondaryFixedVariant': MaterialDynamicColors.onSecondaryFixedVariant,
    'tertiary': MaterialDynamicColors.tertiary,
    'onTertiary': MaterialDynamicColors.onTertiary,
    'tertiaryContainer': MaterialDynamicColors.tertiaryContainer,
    'onTertiaryContainer': MaterialDynamicColors.onTertiaryContainer,
    'tertiaryFixed': MaterialDynamicColors.tertiaryFixed,
    'tertiaryFixedDim': MaterialDynamicColors.tertiaryFixedDim,
    'onTertiaryFixed': MaterialDynamicColors.onTertiaryFixed,
    'onTertiaryFixedVariant': MaterialDynamicColors.onTertiaryFixedVariant,
    'error': MaterialDynamicColors.error,
    'onError': MaterialDynamicColors.onError,
    'errorContainer': MaterialDynamicColors.errorContainer,
    'onErrorContainer': MaterialDynamicColors.onErrorContainer,
    'surface': MaterialDynamicColors.surface,
    'onSurface': MaterialDynamicColors.onSurface,
    'surfaceDim': MaterialDynamicColors.surfaceDim,
    'surfaceBright': MaterialDynamicColors.surfaceBright,
    'surfaceContainerLowest': MaterialDynamicColors.surfaceContainerLowest,
    'surfaceContainerLow': MaterialDynamicColors.surfaceContainerLow,
    'surfaceContainer': MaterialDynamicColors.surfaceContainer,
    'surfaceContainerHigh': MaterialDynamicColors.surfaceContainerHigh,
    'surfaceContainerHighest': MaterialDynamicColors.surfaceContainerHighest,
    'onSurfaceVariant': MaterialDynamicColors.onSurfaceVariant,
    'outline': MaterialDynamicColors.outline,
    'outlineVariant': MaterialDynamicColors.outlineVariant,
    'shadow': MaterialDynamicColors.shadow,
    'scrim': MaterialDynamicColors.scrim,
    'inverseSurface': MaterialDynamicColors.inverseSurface,
    'onInverseSurface': MaterialDynamicColors.inverseOnSurface,
    'inversePrimary': MaterialDynamicColors.inversePrimary,
    'surfaceTint': MaterialDynamicColors.primary,
  };
}
