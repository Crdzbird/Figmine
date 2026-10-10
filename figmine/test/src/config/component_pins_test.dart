import 'package:figmine/src/config/component_pins.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:flutter_test/flutter_test.dart';

FigmineConfig _config(Map<String, Object?> components) =>
    FigmineConfig.fromYaml({
      'figma': {'file_key': 'AbC123xyzAbC'},
      'components': components,
    });

void main() {
  test('components pin measured dimensions by metric name', () {
    final config = _config({'inputHeight': 40, 'inputRadius': '16'});
    expect(config.components, {'inputHeight': 40, 'inputRadius': 16});
    final metrics = ComponentPins.apply({
      'inputHeight': (value: 48, doc: 'Most common across 17 inputs.'),
      'cardRadius': (value: 24, doc: 'Most common across 25 cards.'),
    }, config.components);
    expect(metrics['inputHeight']!.value, 40);
    expect(metrics['inputHeight']!.doc, contains('figmine.yaml'));
    expect(metrics['cardRadius']!.value, 24);
  });

  test('unknown metrics and non numbers are rejected', () {
    expect(
      () => _config({'inputHight': 40}),
      throwsA(
        isA<ConfigException>().having(
          (e) => '$e',
          'message',
          contains('Known metrics'),
        ),
      ),
    );
    expect(
      () => _config({'inputHeight': 'tall'}),
      throwsA(isA<ConfigException>()),
    );
  });
}
