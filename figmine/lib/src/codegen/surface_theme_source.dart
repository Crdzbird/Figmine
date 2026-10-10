/// Source of the generated floating action button, navigation bar, bottom
/// sheet, dialog, snack bar and tooltip themes.
abstract final class SurfaceThemeSource {
  /// The members, given the color scheme class [s] and the components
  /// class [m].
  static String render(String s, String m) =>
      '''
  /// Floating action buttons: fill, icon, size and corners.
  static FloatingActionButtonThemeData fab($s c) =>
      FloatingActionButtonThemeData(
        backgroundColor: c.fab,
        foregroundColor: c.onFab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular($m.fabRadius),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: $m.fabSize,
          height: $m.fabSize,
        ),
      );

  /// Navigation bars: fill, height, and labels and icons per state.
  static NavigationBarThemeData navigationBar($s c, TextTheme t) =>
      NavigationBarThemeData(
        height: $m.navigationBarHeight,
        backgroundColor: c.navigationBar,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => t.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected)
                ? c.onSurface
                : c.onNavigationBar,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? c.onSecondaryContainer
                : c.onNavigationBar,
          ),
        ),
      );

  /// Bottom sheets: fill and top corners.
  static BottomSheetThemeData bottomSheet($s c) => BottomSheetThemeData(
    backgroundColor: c.sheet,
    modalBackgroundColor: c.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular($m.sheetRadius),
      ),
    ),
  );

  /// Dialogs: fill, corners, title and content text.
  static DialogThemeData dialog($s c, TextTheme t) => DialogThemeData(
    backgroundColor: c.dialog,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular($m.dialogRadius),
    ),
    titleTextStyle: t.headlineSmall?.copyWith(color: c.onDialog),
    contentTextStyle: t.bodyMedium?.copyWith(color: c.onDialog),
  );

  /// Snack bars: fill, text, action and corners.
  static SnackBarThemeData snackBar($s c, TextTheme t) => SnackBarThemeData(
    backgroundColor: c.snackbar,
    contentTextStyle: t.bodyMedium?.copyWith(color: c.onSnackbar),
    actionTextColor: c.inversePrimary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular($m.snackbarRadius),
    ),
  );

  /// Tooltips: fill, corners and text.
  static TooltipThemeData tooltip($s c, TextTheme t) => TooltipThemeData(
    decoration: BoxDecoration(
      color: c.tooltip,
      borderRadius: BorderRadius.circular($m.tooltipRadius),
    ),
    textStyle: t.bodySmall?.copyWith(color: c.onTooltip),
  );
''';
}
