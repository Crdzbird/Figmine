import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog styling from the dialogs in Figma.
DialogThemeData createDialogTheme(AppColorScheme colors, TextTheme textTheme) =>
    AppComponentThemes.dialog(colors, textTheme);
