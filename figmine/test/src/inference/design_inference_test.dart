import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/inference/inference_result.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screens_fixture.dart';

InferenceResult _analyze({bool withDark = true}) {
  final nodes = (screenNodesJson['nodes']! as Map).cast<String, Object?>();
  final entries = [
    nodes['1:1']! as Map<String, Object?>,
    if (withDark) nodes['1:2']! as Map<String, Object?>,
  ];
  final first = entries.first;
  return DesignInference.analyze(
    ScreenSet(
      frames: [
        for (final e in entries)
          (page: 'App', node: e['document']! as Map<String, Object?>),
      ],
      components: (first['components']! as Map).map(
        (k, v) => MapEntry('$k', (v as Map).cast<String, Object?>()),
      ),
      componentSets: (first['componentSets']! as Map).map(
        (k, v) => MapEntry('$k', (v as Map).cast<String, Object?>()),
      ),
    ),
    const TokensConfig(),
  );
}

String _hex(TokenCollection c, String role, String mode) =>
    (c.find(role)!.values[mode]!.value as ColorValue).hex;

void main() {
  group(DesignInference, () {
    test('recognizes color roles in light and dark screens', () {
      final colors = _analyze().colors!;
      expect(colors.modes, ['light', 'dark']);
      expect(_hex(colors, 'surface', 'light'), '0xFFFFFFFF');
      expect(_hex(colors, 'surface', 'dark'), '0xFF121212');
      expect(_hex(colors, 'onSurface', 'light'), '0xFF1A1A1A');
      expect(_hex(colors, 'onSurfaceVariant', 'light'), '0xFF6B6B6B');
      expect(_hex(colors, 'primary', 'light'), '0xFF3567F6');
      expect(_hex(colors, 'primary', 'dark'), '0xFF8AA7FF');
      expect(_hex(colors, 'onPrimary', 'dark'), '0xFF000000');
      expect(_hex(colors, 'error', 'light'), '0xFFD40E14');
      expect(_hex(colors, 'outline', 'light'), '0xFF8A8A8A');
      expect(_hex(colors, 'outlineVariant', 'light'), '0xFFE0E0E0');
      expect(_hex(colors, 'surfaceContainerLow', 'light'), '0xFFF5F5F5');
      expect(
        colors.find('primary')!.description,
        contains('Fill of 2 buttons'),
      );
      expect(
        colors.find('error')!.description,
        contains('dark value is derived'),
      );
    });

    test('derives dark values when there are no dark screens', () {
      final colors = _analyze(withDark: false).colors!;
      expect(_hex(colors, 'primary', 'light'), '0xFF3567F6');
      expect(_hex(colors, 'primary', 'dark'), isNot('0xFF3567F6'));
    });

    test('measures spacing, radius, typography and components', () {
      final result = _analyze();
      final layout = result.layout!.tokens.map((t) => t.name);
      expect(layout, containsAll(['spacing/8', 'spacing/16', 'spacing/24']));
      expect(layout, containsAll(['radius/4', 'radius/8', 'radius/full']));
      final styles = {for (final s in result.textStyles) s.name: s};
      expect(styles['bodyLarge']!.fontSize, 16);
      expect(styles['headlineSmall']!.fontWeight, 700);
      expect(styles['labelLarge']!.fontSize, 14);
      expect(styles['bodySmall']!.fontSize, 12);
      expect(styles, hasLength(4));
      final m = result.components;
      expect(m['buttonRadius']!.value, 8);
      expect(m['buttonHeight']!.value, 48);
      expect(m['buttonPaddingHorizontal']!.value, 24);
      expect(m['cardRadius']!.value, 16);
      expect(m['cardElevation']!.value, 4);
      expect(m['inputHeight']!.value, 56);
      expect(m['chipRadius']!.value, 999);
      expect(m['appBarHeight']!.value, 64);
      expect(m['buttonRadius']!.doc, contains('instances'));
    });
  });
}
