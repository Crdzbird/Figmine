import 'package:figmine/src/codegen/themes/theme_spec.dart';

/// Source of the generated checkbox, radio and switch themes.
abstract final class ControlThemeSource {
  /// The themes, given the state picker class [p].
  static List<ThemeSpec> specs(String p) => [
    (
      name: 'Checkbox',
      type: 'CheckboxThemeData',
      text: false,
      doc: 'Checkboxes: fill and check when selected, outlines per state.',
      body:
          '''
CheckboxThemeData(
  fillColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.disabled)
        ? (s.contains(WidgetState.selected) ? c.checkbox.disabled : null)
        : (s.contains(WidgetState.selected) ? c.checkbox.selected : null),
  ),
  checkColor: WidgetStatePropertyAll(c.checkbox.onSelected),
  side: WidgetStateBorderSide.resolveWith(
    (s) => s.contains(WidgetState.selected) && !s.contains(WidgetState.disabled)
        ? BorderSide.none
        : BorderSide(
            width: 2,
            color: s.contains(WidgetState.error)
                ? c.checkbox.errorOutline
                : $p.of(s, c.checkbox.outline, c.checkbox.hoveredOutline,
                    c.checkbox.focusedOutline, c.checkbox.focusedOutline,
                    c.checkbox.disabledOutline),
          ),
  ),
)''',
    ),
    (
      name: 'Radio',
      type: 'RadioThemeData',
      text: false,
      doc: 'Radios: the selected dot and ring, and the outline per state.',
      body: '''
RadioThemeData(
  fillColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.disabled)
        ? c.radio.disabled
        : (s.contains(WidgetState.selected)
              ? c.radio.selected
              : (s.contains(WidgetState.hovered)
                    ? c.radio.hoveredOutline
                    : c.radio.outline)),
  ),
)''',
    ),
    (
      name: 'Switch',
      type: 'SwitchThemeData',
      text: false,
      doc: 'Switches: track, thumb and outline, on and off.',
      body: '''
SwitchThemeData(
  trackColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.disabled)
        ? c.toggle.disabledTrack
        : (s.contains(WidgetState.selected)
              ? c.toggle.trackSelected
              : c.toggle.track),
  ),
  thumbColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.selected)
        ? c.toggle.thumbSelected
        : c.toggle.thumb,
  ),
  trackOutlineColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.selected) ? null : c.toggle.outline,
  ),
)''',
    ),
  ];
}
