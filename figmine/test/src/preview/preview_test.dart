import 'dart:io';

import 'package:figmine/src/preview/preview_section.dart';
import 'package:figmine/src/preview/preview_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the template imports the theme and renders both modes', () {
    final source = PreviewTemplate.render(
      imports: [
        'package:app/theme/tokens/figmine.g.dart',
        'package:flutter/material.dart',
      ],
      light: 'const AppTheme().themeData',
      dark: 'const AppTheme(brightness: Brightness.dark).themeData',
    );
    expect(
      source,
      contains("import 'package:app/theme/tokens/figmine.g.dart';"),
    );
    expect(source, contains("('light', const AppTheme().themeData)"));
    expect(source, contains('Widget _gallery(ThemeData theme)'));
    expect(
      source,
      contains('Map<String, (Color, Color)> _roles(ColorScheme s)'),
    );
    expect(source, isNot(contains('//')));
  });

  test('the section compares with earlier images when they exist', () async {
    final root = await Directory.systemTemp.createTemp('figmine_preview');
    addTearDown(() async => await root.delete(recursive: true));
    final after = PreviewSection.markdown(
      root: root.path,
      after: '.figmine/after',
      before: '.figmine/before',
      base: 'https://github.com/acme/app/blob/figmine/sync',
    );
    expect(after, contains('| | After |'));
    await File('${root.path}/.figmine/before/light.png')
        .create(recursive: true);
    final compared = PreviewSection.markdown(
      root: root.path,
      after: '.figmine/after',
      before: '.figmine/before',
      base: 'https://github.com/acme/app/blob/figmine/sync',
    );
    expect(compared, contains('| | Before | After |'));
    expect(
      compared,
      contains(
        'src="https://github.com/acme/app/blob/figmine/sync/'
        '.figmine/after/dark.png?raw=true"',
      ),
    );
  });
}
