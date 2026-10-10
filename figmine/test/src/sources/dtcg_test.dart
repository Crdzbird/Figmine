import 'dart:io';

import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/dtcg/dtcg_builder.dart';
import 'package:figmine/src/sources/dtcg/file_tokens.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:flutter_test/flutter_test.dart';

Future<DtcgTokens> _load(List<String> files) async => (await FileTokens.load(
  '${Directory.current.path}/test/fixtures',
  TokensConfig(source: TokenSource.file, files: files),
))!;

String _hex(TokenCollection c, String name, String mode) =>
    (c.find(name)!.values[mode]!.value as ColorValue).hex;

void main() {
  test(
    'reads a figmine export with modes, aliases and library values',
    () async {
      final tokens = await _load(['figmine_export.json']);
      final byName = {for (final c in tokens.collections) c.name: c};
      expect(byName.keys, ['_core_colors', 'ui_colors']);
      final core = byName['_core_colors']!;
      expect(core.find('deep-blue/80')!.description, 'Raw deep-blue, stop 80.');
      expect(core.find('size/0_5')!.values['Value']!.value, 2.0);
      final ui = byName['ui_colors']!;
      expect(ui.modes, ['Light', 'Dark']);
      final text = ui.find('text/static/regular')!;
      expect(_hex(ui, 'text/static/regular', 'Light'), '0xFF1B115C');
      expect(_hex(ui, 'text/static/regular', 'Dark'), '0xFFFFFFFF');
      expect(text.values['Light']!.alias!.label, 'deep-blue/80 (_core_colors)');
      expect(_hex(ui, 'fills/brand', 'Dark'), '0xFF3567F6');
      final style = tokens.textStyles.single;
      expect(style.name, 'Body/Large');
      expect(
        [style.fontFamily, style.fontWeight, style.height],
        ['Ambit', 600, 1.5],
      );
      expect(style.italic, isTrue);
      expect(style.letterSpacing, closeTo(-0.32, 0.001));
    },
  );

  test(
    'reads one file per mode with inherited types and cross file aliases',
    () async {
      final tokens = await _load(['dtcg_per_mode']);
      final byName = {for (final c in tokens.collections) c.name: c};
      expect(byName['Semantic']!.modes, ['Dark', 'Light']);
      final semantic = byName['Semantic']!;
      expect(_hex(semantic, 'color/primary', 'Light'), '0xFF3567F6');
      expect(_hex(semantic, 'color/primary', 'Dark'), '0xFF8AA7FF');
      expect(
        semantic.find('color/primary')!.values['Light']!.alias!.label,
        'palette/blue (Primitives)',
      );
      final primitives = byName['Primitives']!;
      expect(_hex(primitives, 'palette/white', 'Value'), '0xFFFFFFFF');
      expect(primitives.find('radius/m')!.values['Value']!.value, 8.0);
      expect(primitives.find('font/body')!.values['Value']!.value, 'Ambit');
      final heading = tokens.textStyles.single;
      expect(
        [heading.fontFamily, heading.fontSize, heading.fontWeight],
        ['Ambit', 24.0, 700],
      );
      expect(heading.height, closeTo(1.333, 0.001));
    },
  );

  test('files are skipped unless configured', () async {
    expect(await FileTokens.load('.', const TokensConfig()), isNull);
  });
}
