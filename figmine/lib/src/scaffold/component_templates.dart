import 'package:figmine/src/scaffold/scaffold_context.dart';

/// Component theme files of the scaffold, keyed by file name.
///
/// Colors come from the generated color scheme, dimensions from the
/// component metrics measured in the screens, and interaction states from
/// the generated component themes.
abstract final class ComponentTemplates {
  /// Returns every component theme source.
  static Map<String, String> render(ScaffoldContext c) {
    final s = c.schemeClass;
    final m = c.componentsClass;
    final t = c.componentThemesClass;
    final head = c.imports([c.material, c.tokens]);
    return {
      'app_bar_theme.dart':
          '''
$head
/// App bar styling built from the design system.
AppBarThemeData createAppBarTheme($s colors, TextTheme textTheme) =>
    AppBarThemeData(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: colors.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 2,
      toolbarHeight: $m.appBarHeight,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: colors.onSurface),
    );
''',
      'card_theme.dart':
          '''
$head
/// Card styling built from the design system.
CardThemeData createCardTheme($s colors) => CardThemeData(
  color: colors.surfaceContainerLow,
  elevation: $m.cardElevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular($m.cardRadius),
    side: BorderSide(color: colors.outlineVariant),
  ),
);
''',
      'chip_theme.dart':
          '''
$head
/// Chip styling built from the design system: resting and selected colors
/// from Figma.
ChipThemeData createChipTheme($s colors, TextTheme textTheme) =>
    $t.chip(colors, textTheme);
''',
      'filled_button_theme.dart':
          '''
$head
/// Filled button styling built from the design system: the colors of each
/// interaction state from Figma. Adjust the returned theme with copyWith.
FilledButtonThemeData createFilledButtonTheme(
  $s colors,
  TextTheme textTheme,
) => $t.filledButton(colors, textTheme);
''',
      'input_decoration_theme.dart':
          '''
$head
/// Text field styling built from the design system: outlines and fills
/// for each state from Figma.
InputDecorationThemeData createInputDecorationTheme($s colors) =>
    $t.inputDecoration(colors);
''',
      'outlined_button_theme.dart':
          '''
$head
/// Outlined button styling built from the design system: fill, label and
/// border for each interaction state from Figma.
OutlinedButtonThemeData createOutlinedButtonTheme(
  $s colors,
  TextTheme textTheme,
) => $t.outlinedButton(colors, textTheme);
''',
    };
  }
}
