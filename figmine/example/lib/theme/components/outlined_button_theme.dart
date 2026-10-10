import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Outlined button styling built from the design system: fill, label and
/// border for each interaction state from Figma.
OutlinedButtonThemeData createOutlinedButtonTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppComponentThemes.outlinedButton(colors, textTheme);
