import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// App bar styling built from the design system.
AppBarThemeData createAppBarTheme(AppColorScheme colors, TextTheme textTheme) =>
    AppBarThemeData(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: colors.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 2,
      toolbarHeight: AppComponents.appBarHeight,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: colors.onSurface),
    );
