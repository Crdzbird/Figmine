import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Text field styling built from the design system: outlines and fills
/// for each state from Figma.
InputDecorationThemeData createInputDecorationTheme(AppColorScheme colors) =>
    AppComponentThemes.inputDecoration(colors);
