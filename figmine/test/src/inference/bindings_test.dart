import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/figma_nodes.dart';

Map<String, Object?> _bound(Map<String, Object?> node, String id) {
  final fills = (node['fills']! as List).cast<Map<String, Object?>>();
  return {
    ...node,
    'fills': [
      {
        ...fills.first,
        'boundVariables': {
          'color': {'type': 'VARIABLE_ALIAS', 'id': id},
        },
      },
    ],
  };
}

void main() {
  test('roles map onto the variables the screens bind them to', () {
    final button = _bound(
      box(
        'b',
        fill: 0x3567F6,
        radius: 8,
        padding: 12,
        children: [text('Book', 0xFFFFFF, size: 14)],
      ),
      'VariableID:9:1',
    );
    final screen = box(
      's',
      fill: 0xFFFFFF,
      width: 375,
      height: 800,
      children: [
        button,
        button,
        text('Body copy that is long enough', 0x1B115C),
      ],
    );
    final result = DesignInference.analyze(
      ScreenSet(frames: [(page: 'App', node: screen)]),
      const TokensConfig(),
    );
    expect(result.evidence.roleVariables['primary'], 'VariableID:9:1');

    const token = DesignToken(
      path: ['fills', 'interactive', 'primary', 'idle'],
      type: TokenType.color,
      values: {'Value': TokenValue(ColorValue(r: 0.2, g: 0.4, b: 0.96))},
      variableId: 'VariableID:9:1',
    );
    final roles = SchemeMatcher(
      const [
        TokenCollection(name: 'ui_colors', modes: ['Value'], tokens: [token]),
      ],
      const SchemeConfig(),
      evidence: result.evidence,
    ).roles();
    expect(roles['primary']!.token.name, 'fills/interactive/primary/idle');

    final warning = SchemeMatcher(
      const [
        TokenCollection(
          name: 'ui_colors',
          modes: ['Value'],
          tokens: [
            DesignToken(
              path: ['icon', 'feedback', 'warning'],
              type: TokenType.color,
              values: {'Value': TokenValue(ColorValue(r: 0.7, g: 0.4, b: 0))},
              variableId: 'VariableID:9:2',
            ),
          ],
        ),
      ],
      const SchemeConfig(),
      evidence: (
        roleVariables: const {'secondary': 'VariableID:9:2'},
        colorUses: const {},
        componentColors: const {},
      ),
    ).roles();
    expect(warning.containsKey('secondary'), isFalse);
  });
}
