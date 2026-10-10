import 'package:figmine_example/theme/tokens/figmine.g.dart';
import 'package:material_ui/material_ui.dart';

/// Switch styling from the switch variants in Figma.
SwitchThemeData createSwitchTheme(AppColorScheme colors) =>
    AppComponentThemes.toggle(colors);
