import 'package:figmine/src/codegen/themes/theme_spec.dart';

/// Source of the generated filled and outlined button themes.
abstract final class ButtonThemeSource {
  /// The themes, given the components class [m] and the state picker
  /// class [p].
  static List<ThemeSpec> specs(String m, String p) => [
    (
      name: 'FilledButton',
      type: 'FilledButtonThemeData',
      text: true,
      doc: 'Filled buttons: resting, hovered, pressed, focused and disabled.',
      body:
          '''
FilledButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (s) => $p.of(s, c.button.color, c.button.hovered, c.button.pressed,
          c.button.focused, c.button.disabled),
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => $p.of(s, c.button.onColor, c.button.onHovered,
          c.button.onPressed, c.button.onFocused, c.button.onDisabled),
    ),
${_shared(m, 64)}
  ),
)''',
    ),
    (
      name: 'OutlinedButton',
      type: 'OutlinedButtonThemeData',
      text: true,
      doc:
          'Outlined buttons: fill, label and border for resting, hovered, '
          'pressed, focused and disabled.',
      body:
          '''
OutlinedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (s) => $p.of(s, c.outlinedButton.color, c.outlinedButton.hovered,
          c.outlinedButton.pressed, c.outlinedButton.focused,
          c.outlinedButton.disabled),
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => $p.of(s, c.outlinedButton.onColor, c.outlinedButton.onHovered,
          c.outlinedButton.onPressed, c.outlinedButton.onFocused,
          c.outlinedButton.onDisabled),
    ),
    side: WidgetStateBorderSide.resolveWith(
      (s) => BorderSide(
        color: $p.of(s, c.outlinedButton.outline,
            c.outlinedButton.hoveredOutline, c.outlinedButton.pressedOutline,
            c.outlinedButton.focusedOutline,
            c.outlinedButton.disabledOutline),
      ),
    ),
${_shared(m, 64)}
  ),
)''',
    ),
  ];

  /// The layer, text, size, padding and corners every button shares, at
  /// least [width] wide.
  static String _shared(String m, int width) =>
      '''
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    textStyle: WidgetStatePropertyAll(t.labelLarge),
    minimumSize: const WidgetStatePropertyAll(Size($width, $m.buttonHeight)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: $m.buttonPaddingHorizontal),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($m.buttonRadius),
      ),
    ),''';
}
