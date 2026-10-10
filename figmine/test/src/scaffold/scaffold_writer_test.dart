import 'package:figmine/src/config/output_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/scaffold/scaffold_context.dart';
import 'package:figmine/src/scaffold/scaffold_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes the theme class, component themes and a barrel', () {
    final files = {
      for (final file in ScaffoldWriter.files(
        const ScaffoldContext(
          output: OutputConfig(),
          project: ProjectInfo(packageName: 'my_app', modernConstructors: true),
        ),
      ))
        file.path: file.contents,
    };
    expect(files.keys, [
      'lib/theme/app_theme.dart',
      'lib/theme/components/app_bar_theme.dart',
      'lib/theme/components/card_theme.dart',
      'lib/theme/components/chip_theme.dart',
      'lib/theme/components/filled_button_theme.dart',
      'lib/theme/components/input_decoration_theme.dart',
      'lib/theme/components/outlined_button_theme.dart',
      'lib/theme/components/checkbox_theme.dart',
      'lib/theme/components/radio_theme.dart',
      'lib/theme/components/switch_theme.dart',
      'lib/theme/components/tab_bar_theme.dart',
      'lib/theme/components/text_button_theme.dart',
      'lib/theme/components/bottom_sheet_theme.dart',
      'lib/theme/components/dialog_theme.dart',
      'lib/theme/components/fab_theme.dart',
      'lib/theme/components/navigation_bar_theme.dart',
      'lib/theme/components/snack_bar_theme.dart',
      'lib/theme/components/tooltip_theme.dart',
      'lib/theme/theme.dart',
    ]);
    final theme = files['lib/theme/app_theme.dart']!;
    expect(theme, contains('final class AppTheme {'));
    expect(theme, contains('const factory({Brightness brightness})'));
    expect(theme, contains('cardTheme: createCardTheme(colors),'));
    expect(
      theme,
      contains("import 'package:my_app/theme/tokens/figmine.g.dart';"),
    );
    expect(
      files['lib/theme/theme.dart'],
      contains("export 'package:my_app/theme/components/card_theme.dart';"),
    );
  });
}
