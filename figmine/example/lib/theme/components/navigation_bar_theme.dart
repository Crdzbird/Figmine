import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Navigation bar styling from the bottom navigation in Figma.
NavigationBarThemeData createNavigationBarTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppComponentThemes.navigationBar(colors, textTheme);
