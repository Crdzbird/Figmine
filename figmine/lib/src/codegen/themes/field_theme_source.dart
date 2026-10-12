import 'package:figmine/src/codegen/themes/theme_spec.dart';

/// Source of the generated text field and chip themes.
abstract final class FieldThemeSource {
  /// The themes, given the components class [m] and the state picker
  /// class [p].
  static List<ThemeSpec> specs(String m, String p) => [
    (
      name: 'InputDecoration',
      type: 'InputDecorationThemeData',
      text: false,
      doc:
          'Text fields: outlines for resting, hovered, focused, error and '
          'disabled, fills for resting and disabled, and labels per state.',
      body:
          '''
InputDecorationThemeData(
  filled: true,
  fillColor: WidgetStateColor.resolveWith(
    (s) => s.contains(WidgetState.disabled)
        ? c.input.disabled
        : c.input.color,
  ),
  hoverColor: Colors.transparent,
  labelStyle: WidgetStateTextStyle.resolveWith(
    (s) => TextStyle(
      color: s.contains(WidgetState.disabled)
          ? c.input.onDisabled
          : c.input.onColor,
    ),
  ),
  floatingLabelStyle: WidgetStateTextStyle.resolveWith(
    (s) => TextStyle(
      color: s.contains(WidgetState.error)
          ? c.input.errorOutline
          : (s.contains(WidgetState.focused)
                ? c.input.focusedOutline
                : (s.contains(WidgetState.disabled)
                      ? c.input.onDisabled
                      : c.input.onColor)),
    ),
  ),
  border: WidgetStateInputBorder.resolveWith(
    (s) => OutlineInputBorder(
      borderRadius: BorderRadius.circular($m.inputRadius),
      borderSide: BorderSide(
        width: s.contains(WidgetState.focused) ? 2 : 1,
        color: s.contains(WidgetState.error)
            ? c.input.errorOutline
            : $p.of(s, c.input.outline, c.input.hoveredOutline,
                c.input.focusedOutline, c.input.focusedOutline,
                c.input.disabledOutline),
      ),
    ),
  ),
)''',
    ),
    (
      name: 'Chip',
      type: 'ChipThemeData',
      text: true,
      doc: 'Chips: resting and selected.',
      body:
          '''
ChipThemeData(
  color: WidgetStateColor.resolveWith(
    (s) => s.contains(WidgetState.selected) ? c.chip.selected : c.chip.color,
  ),
  labelStyle: t.labelLarge?.copyWith(color: c.chip.onColor),
  secondaryLabelStyle: t.labelLarge?.copyWith(color: c.chip.onSelected),
  checkmarkColor: c.chip.onSelected,
  side: WidgetStateBorderSide.resolveWith(
    (s) => s.contains(WidgetState.selected)
        ? BorderSide.none
        : BorderSide(color: c.chip.outline),
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular($m.chipRadius),
  ),
)''',
    ),
  ];
}
