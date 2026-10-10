import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/token_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

FigmineConfig _parse(String yaml) =>
    FigmineConfig.fromYaml(loadYaml(yaml) as Map);

void main() {
  group(FigmineConfig, () {
    test('applies defaults', () {
      final config = _parse('figma:\n  file_key: abc');
      expect(config.fileKey, 'abc');
      expect(config.tokenEnv, 'FIGMA_TOKEN');
      expect(config.tokens.source, TokenSource.auto);
      expect(config.typography.enabled, isTrue);
      expect(config.icons, isNull);
      expect(config.output.directory, 'lib/theme/tokens');
      expect(config.output.themeDirectory, 'lib/theme');
      expect(config.output.classPrefix, 'App');
    });

    test('reads every section', () {
      final config = _parse('''
figma: {file_key: abc, token_env: MY_TOKEN}
tokens:
  source: styles
  collections: {Primitives: Core, Semantic: ""}
  strip_prefix: color/
  light_mode: Day
color_scheme:
  collection: Semantic
  seed: brand
  roles: {primary: brand/primary}
  extra: {success: feedback/success}
typography: {enabled: false, roles: {bodyLarge: Body/L}}
icons: {node_ids: ["12-34"], name_prefix: icon/}
output: {directory: lib/ds, theme_directory: lib/ui, class_prefix: Acme}
''');
      expect(config.tokens.source, TokenSource.styles);
      expect(config.tokens.collections, {'Primitives': 'Core', 'Semantic': ''});
      expect(config.tokens.segmentOf('Primitives'), 'Core');
      expect(config.tokens.includes('Other'), isFalse);
      expect(config.scheme.collection, 'Semantic');
      expect(config.scheme.extra, {'success': 'feedback/success'});
      expect(config.typography.enabled, isFalse);
      expect(config.typography.roles, {'bodyLarge': 'Body/L'});
      expect(config.icons!.nodeIds, ['12:34']);
      expect(config.output.themeDirectory, 'lib/ui');
    });

    test('accepts collections as a list and the legacy colors key', () {
      final config = _parse('''
figma: {file_key: a}
colors: {collections: [Semantic], strip_prefix: c/}
''');
      expect(config.tokens.collections, {'Semantic': null});
      expect(config.tokens.segmentOf('Semantic'), 'Semantic');
      expect(config.tokens.pathOf('c/brand / primary'), ['brand', 'primary']);
    });

    test('rejects misplaced settings and names their section', () {
      expect(
        () => _parse('figma: {file_key: a, files: [x.json]}'),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            '`figma.files` is not a figmine setting. Did you mean '
                '`tokens.files`?',
          ),
        ),
      );
      expect(
        () => _parse('figma: {file_key: a}\ntypo: {}'),
        throwsA(isA<ConfigException>()),
      );
    });

    test('rejects a missing file key and wrong types', () {
      expect(() => _parse('figma: {}'), throwsA(isA<ConfigException>()));
      expect(
        () => _parse('figma: {file_key: a}\ntokens: [1]'),
        throwsA(isA<ConfigException>()),
      );
      expect(
        () => _parse('figma: {file_key: a}\ntypography: {enabled: maybe}'),
        throwsA(isA<ConfigException>()),
      );
    });
  });
}
