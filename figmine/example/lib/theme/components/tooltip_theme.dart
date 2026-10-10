import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Tooltip styling from the tooltips in Figma.
TooltipThemeData createTooltipTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppComponentThemes.tooltip(colors, textTheme);
