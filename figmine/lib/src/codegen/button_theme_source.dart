/// Source of the generated filled and outlined button themes and their
/// state picker.
abstract final class ButtonThemeSource {
  /// The members, given the color scheme class [s] and the components
  /// class [m].
  static String render(String s, String m) =>
      '''
  /// Filled buttons: resting, hovered, pressed, focused and disabled.
  static FilledButtonThemeData filledButton($s c, TextTheme t) =>
      FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => pick(s, c.button, c.buttonHovered, c.buttonPressed,
                c.buttonFocused, c.buttonDisabled),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => pick(s, c.onButton, c.onButtonHovered, c.onButtonPressed,
                c.onButtonFocused, c.onButtonDisabled),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          minimumSize: const WidgetStatePropertyAll(
            Size(64, $m.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: $m.buttonPaddingHorizontal),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular($m.buttonRadius),
            ),
          ),
        ),
      );

  /// Outlined buttons: fill, label and border for resting, hovered,
  /// pressed, focused and disabled.
  static OutlinedButtonThemeData outlinedButton($s c, TextTheme t) =>
      OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => pick(s, c.outlinedButton, c.outlinedButtonHovered,
                c.outlinedButtonPressed, c.outlinedButtonFocused,
                c.outlinedButtonDisabled),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => pick(s, c.onOutlinedButton, c.onOutlinedButtonHovered,
                c.onOutlinedButtonPressed, c.onOutlinedButtonFocused,
                c.onOutlinedButtonDisabled),
          ),
          side: WidgetStateBorderSide.resolveWith(
            (s) => BorderSide(
              color: pick(s, c.outlinedButtonOutline,
                  c.outlinedButtonHoveredOutline,
                  c.outlinedButtonPressedOutline,
                  c.outlinedButtonFocusedOutline,
                  c.outlinedButtonDisabledOutline),
            ),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          minimumSize: const WidgetStatePropertyAll(
            Size(64, $m.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: $m.buttonPaddingHorizontal),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular($m.buttonRadius),
            ),
          ),
        ),
      );

  /// The color of [states]: disabled first, then pressed, focused and
  /// hovered, or [rest].
  static Color pick(Set<WidgetState> states, Color rest, Color hovered,
      Color pressed, Color focused, Color disabled) {
    if (states.contains(WidgetState.disabled)) return disabled;
    if (states.contains(WidgetState.pressed)) return pressed;
    if (states.contains(WidgetState.focused)) return focused;
    if (states.contains(WidgetState.hovered)) return hovered;
    return rest;
  }
''';
}
