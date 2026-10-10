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
    'fabRadius': 16,
    'fabSize': 56,
    'navigationBarHeight': 80,
    'sheetRadius': 28,
    'dialogRadius': 28,
    'snackbarRadius': 4,
    'tooltipRadius': 4,
  };

  /// Plausible range of each metric; samples outside are ignored, such as
  /// a hero header counted as an app bar.
  static const Map<String, (double, double)> ranges = {
    'buttonHeight': (24, 72),
    'buttonPaddingHorizontal': (4, 48),
    'cardPadding': (4, 48),
    'inputHeight': (32, 80),
    'appBarHeight': (40, 128),
    'fabSize': (32, 120),
    'navigationBarHeight': (48, 120),
    'sheetRadius': (0, 48),
    'dialogRadius': (0, 48),
    'snackbarRadius': (0, 32),
    'tooltipRadius': (0, 24),
  };
}
