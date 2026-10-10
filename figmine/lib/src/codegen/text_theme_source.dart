/// Source of the generated text button and tab bar themes.
abstract final class TextThemeSource {
  /// The members, given the color scheme class [s] and the components
  /// class [m].
  static String render(String s, String m) =>
      '''
  /// Text buttons: label per state, with hovered and pressed layers.
  static TextButtonThemeData textButton($s c, TextTheme t) =>
      TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? c.onTextButtonDisabled
                : c.onTextButton,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed)
                ? c.textButtonPressed
                : (s.contains(WidgetState.hovered) ? c.textButtonHovered : null),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          minimumSize: const WidgetStatePropertyAll(Size(48, $m.buttonHeight)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular($m.buttonRadius),
            ),
          ),
        ),
      );

  /// Tab bars: selected and unselected labels and the indicator.
  static TabBarThemeData tabBar($s c, TextTheme t) => TabBarThemeData(
    labelColor: c.tabLabel,
    unselectedLabelColor: c.tabUnselectedLabel,
    indicatorColor: c.tabIndicator,
    labelStyle: t.titleSmall,
    unselectedLabelStyle: t.titleSmall,
  );
''';
}
