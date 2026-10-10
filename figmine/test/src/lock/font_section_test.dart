import 'dart:io';

import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/lock/font_section.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

TextStyleToken _style(String family) => TextStyleToken(
  path: [family],
  fontFamily: family,
  fontSize: 16,
  fontWeight: 400,
);

void main() {
  test('fonts the pubspec bundles and platform fonts are not missing', () {
    final missing = FontSection.missing(
      [
        _style('Inter'),
        _style('Inter'),
        _style('Brand Serif'),
        _style('roboto'),
        _style('SF Pro Text'),
      ],
      {'brand serif'.toUpperCase()},
    );
    expect(missing, [(family: 'Inter', styles: 2)]);
    final buffer = StringBuffer();
    FontSection.write(buffer, missing);
    expect('$buffer', contains('- `Inter`, in 2 text styles'));
    expect(FontSection.log(missing).single, startsWith('Font Inter is used'));
  });

  test('project info reads the bundled font families', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_fonts');
    addTearDown(() => dir.delete(recursive: true));
    await File(p.join(dir.path, 'pubspec.yaml')).writeAsString('''
name: app
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter.ttf
''');
    final info = await ProjectInfo.read(dir.path);
    expect(info.fonts, {'Inter'});
  });
}
