/// Source of the generated checkbox, radio and switch themes.
abstract final class ControlThemeSource {
  /// The members, given the color scheme class [s].
  static String render(String s) =>
      '''
  /// Checkboxes: fill and check when selected, outlines per state.
  static CheckboxThemeData checkbox($s c) => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? (s.contains(WidgetState.selected) ? c.checkboxDisabled : null)
          : (s.contains(WidgetState.selected) ? c.checkboxSelected : null),
    ),
    checkColor: WidgetStatePropertyAll(c.onCheckboxSelected),
    side: WidgetStateBorderSide.resolveWith(
      (s) => s.contains(WidgetState.selected) && !s.contains(WidgetState.disabled)
          ? BorderSide.none
          : BorderSide(
              width: 2,
              color: s.contains(WidgetState.error)
                  ? c.checkboxErrorOutline
                  : pick(s, c.checkboxOutline, c.checkboxHoveredOutline,
                      c.checkboxFocusedOutline, c.checkboxFocusedOutline,
                      c.checkboxDisabledOutline),
            ),
    ),
  );

  /// Radios: the selected dot and ring, and the outline per state.
  static RadioThemeData radio($s c) => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? c.radioDisabled
          : (s.contains(WidgetState.selected)
                ? c.radioSelected
                : (s.contains(WidgetState.hovered)
                      ? c.radioHoveredOutline
                      : c.radioOutline)),
    ),
  );

  /// Switches: track, thumb and outline, on and off.
  static SwitchThemeData toggle($s c) => SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? c.switchDisabledTrack
          : (s.contains(WidgetState.selected)
                ? c.switchTrackSelected
                : c.switchTrack),
    ),
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? c.switchThumbSelected
          : c.switchThumb,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? null : c.switchOutline,
    ),
  );
''';
}
