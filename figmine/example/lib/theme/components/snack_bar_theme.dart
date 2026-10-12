import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Snack bar styling from the snack bars and toasts in Figma.
SnackBarThemeData createSnackBarTheme(
  AppColorScheme colors,
  TextTheme textTheme,
) => AppSnackBarTheme.of(colors, textTheme);
