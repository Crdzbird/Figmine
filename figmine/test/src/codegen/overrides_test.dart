import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../helpers/sample_tokens.dart';

FigmineConfig _config(String overrides) => FigmineConfig.fromYaml(
  loadYaml('''
figma: {file_key: AbC123xyzAbC}
color_scheme:
  overrides: $overrides
''') as Map,
);

void main() {
  test('overrides win over Figma and can add fields', () {
    final config = _config(
      '{primary: "#1B115C", success: {light: "#1C875B", dark: "#7BD8A8"}}',
    );
    final fields = {
      for (final f in SchemeFields.resolve(
        matcher: SchemeMatcher(sampleTokens.collections, config.scheme),
        index: TokenIndex(
          collections: sampleTokens.collections,
          prefix: 'App',
          config: const TokensConfig(),
        ),
        tokens: const TokensConfig(),
      ))
        f.name: f,
    };
    expect(fields['primary']!.light.code, 'Color(0xFF1B115C)');
    final dark = fields['primary']!.darkArgb;
    expect(ColorMath.luminance(dark), greaterThan(0.4));
    expect(ColorMath.hueDistance(dark, 0xFF1B115C), lessThan(15));
    expect(fields['primary']!.doc, contains('dark value is derived'));
    expect(fields['primary']!.doc, contains('overrides'));
    expect(fields['success']!.dark.code, 'Color(0xFF7BD8A8)');
  });

  test('rejects values that are not colors', () {
    expect(() => _config('{primary: blue}'), throwsA(isA<ConfigException>()));
    expect(() => _config('[1]'), throwsA(isA<ConfigException>()));
  });
}
