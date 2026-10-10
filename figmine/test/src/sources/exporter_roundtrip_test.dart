import 'dart:io';

import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/dtcg/file_tokens.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hasNode = Process.runSync('which', ['node']).exitCode == 0;

  test('the exporter plugin output imports cleanly', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_exporter');
    addTearDown(() async => await dir.delete(recursive: true));
    final out = '${dir.path}/design-tokens.json';
    final run = await Process.run('node', ['tool/exporter_mock.js', out]);
    expect(run.exitCode, 0, reason: '${run.stderr}');
    final tokens = await FileTokens.load(
      dir.path,
      const TokensConfig(
        source: TokenSource.file,
        files: ['design-tokens.json'],
      ),
    );
    expect(tokens!.collections.map((c) => c.name), [
      '_core_colors',
      'ui_colors',
      'Effects',
    ]);
    expect(tokens.collections[1].tokens, hasLength(2));
    final effects = tokens.collections.last.tokens;
    Object value(TokenType type) =>
        effects.firstWhere((t) => t.type == type).values.values.single.value;
    final shadow = value(TokenType.shadow) as ShadowValue;
    expect(shadow.layers.single.blur, 4);
    expect(shadow.layers.single.color.hex, '0x40000000');
    final gradient = value(TokenType.gradient) as GradientValue;
    expect(gradient.handles.take(2), [(0.0, 0.5), (1.0, 0.5)]);
    expect(tokens.textStyles.single.fontFamily, 'Ambit');
    expect(tokens.textStyles.single.decoration, 'underline');
  }, skip: hasNode ? false : 'node is not installed');
}
