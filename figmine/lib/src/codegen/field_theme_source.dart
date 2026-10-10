/// Source of the generated text field and chip themes.
abstract final class FieldThemeSource {
  /// The members, given the color scheme class [s] and the components
  /// class [m].
  static String render(String s, String m) =>
      '''
  /// Text fields: outlines for resting, hovered, focused, error and
  /// disabled, and fills for resting and disabled.
  static InputDecorationThemeData inputDecoration($s c) =>
      InputDecorationThemeData(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? c.inputDisabled : c.input,
        ),
        hoverColor: Colors.transparent,
        border: WidgetStateInputBorder.resolveWith(
          (s) => OutlineInputBorder(
            borderRadius: BorderRadius.circular($m.inputRadius),
            borderSide: BorderSide(
              width: s.contains(WidgetState.focused) ? 2 : 1,
              color: s.contains(WidgetState.error)
                  ? c.inputErrorOutline
                  : pick(s, c.inputOutline, c.inputHoveredOutline,
                      c.inputFocusedOutline, c.inputFocusedOutline,
                      c.inputDisabledOutline),
            ),
          ),
        ),
      );

  /// Chips: resting and selected.
  static ChipThemeData chip($s c, TextTheme t) => ChipThemeData(
    color: WidgetStateColor.resolveWith(
      (s) => s.contains(WidgetState.selected) ? c.chipSelected : c.chip,
    ),
    labelStyle: t.labelLarge?.copyWith(color: c.onChip),
    secondaryLabelStyle: t.labelLarge?.copyWith(color: c.onChipSelected),
    checkmarkColor: c.onChipSelected,
    side: WidgetStateBorderSide.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? BorderSide.none
          : BorderSide(color: c.chipOutline),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular($m.chipRadius),
    ),
  );
''';
}
