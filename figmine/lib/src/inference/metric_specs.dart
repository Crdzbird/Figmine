/// Defaults and plausible ranges of component dimensions.
abstract final class MetricSpecs {
  /// Material 3 defaults, used when the screens have no such component.
  static const Map<String, double> defaults = {
    'buttonRadius': 20,
    'buttonHeight': 40,
    'buttonPaddingHorizontal': 24,
    'cardRadius': 12,
    'cardPadding': 16,
    'cardElevation': 1,
    'inputRadius': 4,
    'inputHeight': 56,
    'chipRadius': 8,
    'appBarHeight': 64,
  };

  /// Plausible range of each metric; samples outside are ignored, such as
  /// a hero header counted as an app bar.
  static const Map<String, (double, double)> ranges = {
    'buttonHeight': (24, 72),
    'buttonPaddingHorizontal': (4, 48),
    'cardPadding': (4, 48),
    'inputHeight': (32, 80),
    'appBarHeight': (40, 128),
  };
}
