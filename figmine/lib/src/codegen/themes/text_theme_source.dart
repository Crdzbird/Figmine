import 'package:figmine/src/codegen/themes/theme_spec.dart';

/// Source of the generated text button and tab bar themes.
abstract final class TextThemeSource {
  /// The themes, given the components class [m].
  static List<ThemeSpec> specs(String m) => [
    (
      name: 'TextButton',
      type: 'TextButtonThemeData',
      text: true,
      doc: 'Text buttons: label per state, with hovered and pressed layers.',
      body:
          '''
TextButtonThemeData(
  style: ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? c.textButton.onDisabled
          : c.textButton.onColor,
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.pressed)
          ? c.textButton.pressed
          : (s.contains(WidgetState.hovered) ? c.textButton.hovered : null),
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
)''',
    ),
    (
      name: 'TabBar',
      type: 'TabBarThemeData',
      text: true,
      doc: 'Tab bars: selected and unselected labels and the indicator.',
      body: '''
TabBarThemeData(
  labelColor: c.tab.label,
  unselectedLabelColor: c.tab.unselectedLabel,
  indicatorColor: c.tab.indicator,
  labelStyle: t.titleSmall,
  unselectedLabelStyle: t.titleSmall,
)''',
    ),
  ];
}
