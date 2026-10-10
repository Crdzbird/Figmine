/// Role names of Material's ColorScheme and TextTheme.
abstract final class MaterialRoles {
  /// Every non deprecated ColorScheme role.
  static final List<String> colorScheme = [
    'primary onPrimary primaryContainer onPrimaryContainer primaryFixed ',
    'primaryFixedDim onPrimaryFixed onPrimaryFixedVariant secondary ',
    'onSecondary secondaryContainer onSecondaryContainer secondaryFixed ',
    'secondaryFixedDim onSecondaryFixed onSecondaryFixedVariant tertiary ',
    'onTertiary tertiaryContainer onTertiaryContainer tertiaryFixed ',
    'tertiaryFixedDim onTertiaryFixed onTertiaryFixedVariant error onError ',
    'errorContainer onErrorContainer surface onSurface surfaceDim ',
    'surfaceBright surfaceContainerLowest surfaceContainerLow ',
    'surfaceContainer surfaceContainerHigh surfaceContainerHighest ',
    'onSurfaceVariant outline outlineVariant shadow scrim inverseSurface ',
    'onInverseSurface inversePrimary surfaceTint',
  ].join().split(' ');

  /// Material 3 font size and weight of each TextTheme role, in order.
  static const List<(double, int)> textSpecs = [
    (57, 400),
    (45, 400),
    (36, 400),
    (32, 400),
    (28, 400),
    (24, 400),
    (22, 400),
    (16, 500),
    (14, 500),
    (16, 400),
    (14, 400),
    (12, 400),
    (14, 500),
    (12, 500),
    (11, 500),
  ];

  /// Every TextTheme role.
  static final List<String> textTheme = [
    'displayLarge displayMedium displaySmall headlineLarge headlineMedium ',
    'headlineSmall titleLarge titleMedium titleSmall bodyLarge bodyMedium ',
    'bodySmall labelLarge labelMedium labelSmall',
  ].join().split(' ');
}
