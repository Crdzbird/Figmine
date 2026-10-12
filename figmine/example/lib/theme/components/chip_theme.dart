import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Chip styling built from the design system: resting and selected colors
/// from Figma.
ChipThemeData createChipTheme(AppColorScheme colors, TextTheme textTheme) =>
    AppChipTheme.of(colors, textTheme);
