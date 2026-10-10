import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Tab bar styling from the tab variants in Figma.
TabBarThemeData createTabBarTheme(AppColorScheme colors, TextTheme textTheme) =>
    AppComponentThemes.tabBar(colors, textTheme);
