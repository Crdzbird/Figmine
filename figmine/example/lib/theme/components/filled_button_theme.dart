import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Filled button styling built from the design system: the colors of each
/// interaction state from Figma. Adjust the returned theme with copyWith.
FilledButtonThemeData createFilledButtonTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppFilledButtonTheme.of(colors, textTheme);
