import 'package:figmine/src/scaffold/scaffold_context.dart';

/// Scaffold files of the floating action button, navigation bar, bottom
/// sheet, dialog, snack bar and tooltip themes, keyed by file name.
abstract final class SurfaceTemplates {
  /// Returns every surface theme source.
  static Map<String, String> render(ScaffoldContext c) {
    final s = c.schemeClass;
    final t = c.componentThemesClass;
    final head = c.imports([c.material, c.tokens]);
    String file(String doc, String type, String name, String call) =>
        '''
$head
/// $doc
$type $name =>
    $t.$call;
''';
    return {
      'bottom_sheet_theme.dart': file(
        'Bottom sheet styling from the sheets in Figma.',
        'BottomSheetThemeData',
        'createBottomSheetTheme($s colors)',
        'bottomSheet(colors)',
      ),
      'dialog_theme.dart': file(
        'Dialog styling from the dialogs in Figma.',
        'DialogThemeData',
        'createDialogTheme($s colors, TextTheme textTheme)',
        'dialog(colors, textTheme)',
      ),
      'fab_theme.dart': file(
        'Floating action button styling from Figma.',
        'FloatingActionButtonThemeData',
        'createFabTheme($s colors)',
        'fab(colors)',
      ),
      'navigation_bar_theme.dart': file(
        'Navigation bar styling from the bottom navigation in Figma.',
        'NavigationBarThemeData',
        'createNavigationBarTheme($s colors, TextTheme textTheme)',
        'navigationBar(colors, textTheme)',
      ),
      'snack_bar_theme.dart': file(
        'Snack bar styling from the snack bars and toasts in Figma.',
        'SnackBarThemeData',
        'createSnackBarTheme($s colors, TextTheme textTheme)',
        'snackBar(colors, textTheme)',
      ),
      'tooltip_theme.dart': file(
        'Tooltip styling from the tooltips in Figma.',
        'TooltipThemeData',
        'createTooltipTheme($s colors, TextTheme textTheme)',
        'tooltip(colors, textTheme)',
      ),
    };
  }
}
