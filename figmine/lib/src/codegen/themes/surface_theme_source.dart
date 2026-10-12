import 'package:figmine/src/codegen/themes/theme_spec.dart';

/// Source of the generated floating action button, navigation bar, bottom
/// sheet, dialog, snack bar and tooltip themes.
abstract final class SurfaceThemeSource {
  static ThemeSpec _spec(String name, String doc, bool text, String body) =>
      (name: name, type: '${name}ThemeData', text: text, doc: doc, body: body);

  /// The themes, given the components class [m].
  static List<ThemeSpec> specs(String m) => [
    (
      name: 'Fab',
      type: 'FloatingActionButtonThemeData',
      text: false,
      doc: 'Floating action buttons: fill, icon, size and corners.',
      body:
          '''
FloatingActionButtonThemeData(
  backgroundColor: c.fab.color,
  foregroundColor: c.fab.onColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular($m.fabRadius),
  ),
  sizeConstraints: const BoxConstraints.tightFor(
    width: $m.fabSize,
    height: $m.fabSize,
  ),
)''',
    ),
    _spec(
      'NavigationBar',
      'Navigation bars: fill, height, and labels and '
          'icons per state.',
      true,
      '''
NavigationBarThemeData(
  height: $m.navigationBarHeight,
  backgroundColor: c.navigationBar.color,
  labelTextStyle: WidgetStateProperty.resolveWith(
    (s) => t.labelMedium?.copyWith(
      color: s.contains(WidgetState.selected)
          ? c.onSurface
          : c.navigationBar.onColor,
    ),
  ),
  iconTheme: WidgetStateProperty.resolveWith(
    (s) => IconThemeData(
      color: s.contains(WidgetState.selected)
          ? c.onSecondaryContainer
          : c.navigationBar.onColor,
    ),
  ),
)''',
    ),
    _spec('BottomSheet', 'Bottom sheets: fill and top corners.', false, '''
BottomSheetThemeData(
  backgroundColor: c.sheet.color,
  modalBackgroundColor: c.sheet.color,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular($m.sheetRadius)),
  ),
)'''),
    _spec('Dialog', 'Dialogs: fill, corners, title and content text.', true, '''
DialogThemeData(
  backgroundColor: c.dialog.color,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular($m.dialogRadius),
  ),
  titleTextStyle: t.headlineSmall?.copyWith(color: c.dialog.onColor),
  contentTextStyle: t.bodyMedium?.copyWith(color: c.dialog.onColor),
)'''),
    _spec('SnackBar', 'Snack bars: fill, text, action and corners.', true, '''
SnackBarThemeData(
  backgroundColor: c.snackbar.color,
  contentTextStyle: t.bodyMedium?.copyWith(color: c.snackbar.onColor),
  actionTextColor: c.inversePrimary,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular($m.snackbarRadius),
  ),
)'''),
    _spec('Tooltip', 'Tooltips: fill, corners and text.', true, '''
TooltipThemeData(
  decoration: BoxDecoration(
    color: c.tooltip.color,
    borderRadius: BorderRadius.circular($m.tooltipRadius),
  ),
  textStyle: t.bodySmall?.copyWith(color: c.tooltip.onColor),
)'''),
  ];
}
