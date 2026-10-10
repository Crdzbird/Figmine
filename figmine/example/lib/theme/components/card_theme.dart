import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Card styling built from the design system.
CardThemeData createCardTheme(AppColorScheme colors) => CardThemeData(
  color: colors.surfaceContainerLow,
  elevation: AppComponents.cardElevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppComponents.cardRadius),
    side: BorderSide(color: colors.outlineVariant),
  ),
);
