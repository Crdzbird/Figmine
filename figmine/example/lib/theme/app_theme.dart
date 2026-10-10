import 'package:figmine_example/theme/components/app_bar_theme.dart';
import 'package:figmine_example/theme/components/card_theme.dart';
import 'package:figmine_example/theme/components/checkbox_theme.dart';
import 'package:figmine_example/theme/components/chip_theme.dart';
import 'package:figmine_example/theme/components/filled_button_theme.dart';
import 'package:figmine_example/theme/components/input_decoration_theme.dart';
import 'package:figmine_example/theme/components/outlined_button_theme.dart';
import 'package:figmine_example/theme/components/radio_theme.dart';
import 'package:figmine_example/theme/components/switch_theme.dart';
import 'package:figmine_example/theme/components/tab_bar_theme.dart';
import 'package:figmine_example/theme/components/text_button_theme.dart';
import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// The app theme, assembled from the Figma tokens.
///
/// figmine created this file once and never overwrites it. Tune the
/// component themes next to it, and add new ones as the design grows.
final class AppTheme {
  /// Creates the theme for [brightness].
  const factory({Brightness brightness}) = AppTheme._;

  const new _({this.brightness = Brightness.light});

  /// Whether this is the light or the dark theme.
  final Brightness brightness;

  /// The generated color scheme for [brightness].
  AppColorScheme get colorScheme => brightness == Brightness.dark
      ? AppColorScheme.dark
      : AppColorScheme.light;

  /// The [ThemeData] for [brightness].
  ThemeData get themeData {
    final colors = colorScheme;
    const textTheme = AppTypography.textTheme;
    return ThemeData(
      brightness: brightness,
      colorScheme: colors.toColorScheme(),
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: createAppBarTheme(colors, textTheme),
      cardTheme: createCardTheme(colors),
      checkboxTheme: createCheckboxTheme(colors),
      chipTheme: createChipTheme(colors, textTheme),
      filledButtonTheme: createFilledButtonTheme(colors, textTheme),
      inputDecorationTheme: createInputDecorationTheme(colors),
      outlinedButtonTheme: createOutlinedButtonTheme(colors, textTheme),
      radioTheme: createRadioTheme(colors),
      switchTheme: createSwitchTheme(colors),
      tabBarTheme: createTabBarTheme(colors, textTheme),
      textButtonTheme: createTextButtonTheme(colors, textTheme),
      extensions: [colors],
    );
  }
}
