import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Text button styling from the text button variants in Figma.
TextButtonThemeData createTextButtonTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppTextButtonTheme.of(colors, textTheme);
