import 'package:figmine/src/scaffold/scaffold_context.dart';

/// The theme class of the scaffold.
abstract final class ThemeTemplate {
  /// Component theme files and the function each one declares.
  static const Map<String, String> components = {
    'app_bar_theme.dart': 'createAppBarTheme(colors, textTheme)',
    'bottom_sheet_theme.dart': 'createBottomSheetTheme(colors)',
    'card_theme.dart': 'createCardTheme(colors)',
    'checkbox_theme.dart': 'createCheckboxTheme(colors)',
    'chip_theme.dart': 'createChipTheme(colors, textTheme)',
    'dialog_theme.dart': 'createDialogTheme(colors, textTheme)',
    'fab_theme.dart': 'createFabTheme(colors)',
    'filled_button_theme.dart': 'createFilledButtonTheme(colors, textTheme)',
    'input_decoration_theme.dart': 'createInputDecorationTheme(colors)',
    'navigation_bar_theme.dart': 'createNavigationBarTheme(colors, textTheme)',
    'outlined_button_theme.dart':
        'createOutlinedButtonTheme(colors, textTheme)',
    'radio_theme.dart': 'createRadioTheme(colors)',
    'snack_bar_theme.dart': 'createSnackBarTheme(colors, textTheme)',
    'switch_theme.dart': 'createSwitchTheme(colors)',
    'tab_bar_theme.dart': 'createTabBarTheme(colors, textTheme)',
    'text_button_theme.dart': 'createTextButtonTheme(colors, textTheme)',
    'tooltip_theme.dart': 'createTooltipTheme(colors, textTheme)',
  };

  /// Returns the theme class source.
  static String render(ScaffoldContext c) {
    final theme = c.themeClass;
    final scheme = c.schemeClass;
    return '''
${c.imports([c.material, c.tokens, for (final f in components.keys) c.theme('components/$f')])}
/// The app theme, assembled from the Figma tokens.
///
/// figmine created this file once and never overwrites it. Tune the
/// component themes next to it, and add new ones as the design grows.
final class $theme {
  /// Creates the theme for [brightness].
  ${c.publicFactory(theme)}({Brightness brightness}) = $theme._;

  ${c.privateConstructor(theme)}({this.brightness = Brightness.light});

  /// Whether this is the light or the dark theme.
  final Brightness brightness;

  /// The generated color scheme for [brightness].
  $scheme get colorScheme => brightness == Brightness.dark
      ? $scheme.dark
      : $scheme.light;

  /// The [ThemeData] for [brightness].
  ThemeData get themeData {
    final colors = colorScheme;
    const textTheme = ${c.typographyClass}.textTheme;
    return ThemeData(
      brightness: brightness,
      colorScheme: colors.toColorScheme(),
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: ${components['app_bar_theme.dart']},
      bottomSheetTheme: ${components['bottom_sheet_theme.dart']},
      cardTheme: ${components['card_theme.dart']},
      checkboxTheme: ${components['checkbox_theme.dart']},
      chipTheme: ${components['chip_theme.dart']},
      dialogTheme: ${components['dialog_theme.dart']},
      filledButtonTheme: ${components['filled_button_theme.dart']},
      floatingActionButtonTheme: ${components['fab_theme.dart']},
      inputDecorationTheme: ${components['input_decoration_theme.dart']},
      navigationBarTheme: ${components['navigation_bar_theme.dart']},
      outlinedButtonTheme: ${components['outlined_button_theme.dart']},
      radioTheme: ${components['radio_theme.dart']},
      snackBarTheme: ${components['snack_bar_theme.dart']},
      switchTheme: ${components['switch_theme.dart']},
      tabBarTheme: ${components['tab_bar_theme.dart']},
      textButtonTheme: ${components['text_button_theme.dart']},
      tooltipTheme: ${components['tooltip_theme.dart']},
      extensions: [colors],
    );
  }
}
''';
  }
}
