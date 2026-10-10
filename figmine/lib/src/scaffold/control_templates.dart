import 'package:figmine/src/scaffold/scaffold_context.dart';

/// Scaffold files of the checkbox, radio, switch, tab bar and text button
/// themes, keyed by file name.
abstract final class ControlTemplates {
  /// Returns every control theme source.
  static Map<String, String> render(ScaffoldContext c) {
    final s = c.schemeClass;
    final t = c.componentThemesClass;
    final head = c.imports([c.material, c.tokens]);
    String file(String doc, String type, String name, String call) =>
        '''
$head
/// $doc
$type $name =>
    $t.$call;
''';
    return {
      'checkbox_theme.dart': file(
        'Checkbox styling from the checkbox variants in Figma.',
        'CheckboxThemeData',
        'createCheckboxTheme($s colors)',
        'checkbox(colors)',
      ),
      'radio_theme.dart': file(
        'Radio styling from the radio variants in Figma.',
        'RadioThemeData',
        'createRadioTheme($s colors)',
        'radio(colors)',
      ),
      'switch_theme.dart': file(
        'Switch styling from the switch variants in Figma.',
        'SwitchThemeData',
        'createSwitchTheme($s colors)',
        'toggle(colors)',
      ),
      'tab_bar_theme.dart': file(
        'Tab bar styling from the tab variants in Figma.',
        'TabBarThemeData',
        'createTabBarTheme($s colors, TextTheme textTheme)',
        'tabBar(colors, textTheme)',
      ),
      'text_button_theme.dart': file(
        'Text button styling from the text button variants in Figma.',
        'TextButtonThemeData',
        'createTextButtonTheme($s colors, TextTheme textTheme)',
        'textButton(colors, textTheme)',
      ),
    };
  }
}
