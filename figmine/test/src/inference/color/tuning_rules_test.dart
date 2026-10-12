import 'package:figmine/src/codegen/scheme/binding_lookup.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/color/feedback_roles.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_samples.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentSample _button(String name, {int? label = 1, int? fill = 1}) => (
  kind: ComponentKind.button,
  name: name,
  instance: true,
  definition: false,
  family: name.split(' | ').first,
  fill: fill,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: label,
  labelVariable: null,
  radius: 8,
  pill: false,
  height: 40,
  paddingHorizontal: 16,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('navy and blue are distinct accents despite a close hue', () {
    expect(ColorMath.distinct(0xFF1B115C, 0xFF3567F6), isTrue);
    expect(ColorMath.distinct(0xFF3567F6, 0xFF3A6BF0), isFalse);
  });

  test('feedback colors skip pale container tints', () {
    final stats = UsageStats()
      ..backgroundLayers.addAll({
        0xFFB7F0C8: 90,
        0xFF1C875B: 10,
        0xFFB36206: 5,
      });
    final roles = <String, InferredColor>{
      'surface': (argb: 0xFFFFFFFF, evidence: ''),
    };
    FeedbackRoles.infer(roles, stats);
    expect(roles['success']!.argb, 0xFF1C875B);
    expect(roles['warning']!.argb, 0xFFB36206);
  });

  test('bound colors prefer the closest fill over icons and states', () {
    DesignToken token(String name, String id) => DesignToken(
      path: name.split('/'),
      type: TokenType.color,
      values: const {'Value': TokenValue(ColorValue(r: 0.2, g: 0.4, b: 0.96))},
      variableId: id,
    );
    final collection = TokenCollection(
      name: 'ui',
      modes: const ['Value'],
      tokens: [
        token('icon/interactive/positive/primary/idle', 'V:icon'),
        token('fills/interactive/negative/primary/inverse', 'V:inverse'),
        token('fills/interactive/positive/primary/idle', 'V:fill'),
      ],
    );
    final all = [
      for (final t in collection.tokens) (collection: collection, token: t),
    ];
    final picked = BindingLookup.forRole('primary', {'primary': 'V:icon'}, all);
    expect(picked!.token.name, 'fills/interactive/positive/primary/idle');
  });

  test('buttons are measured on labelled, filled, medium variants', () {
    final picked = ComponentSamples.select(ComponentKind.button, [
      _button('button | type=icon', label: null),
      _button('button | type=text-button', fill: null),
      _button('button-item | size=s'),
      for (var i = 0; i < 3; i++) _button('primary buttons | size=medium'),
      _button('primary buttons | size=small'),
    ]);
    expect(picked.label, 'resting primary medium `primary buttons` instances');
    expect(picked.samples, hasLength(3));
    final fallback = ComponentSamples.select(ComponentKind.button, [
      _button('button | size=medium'),
      _button('button | size=small'),
    ]);
    expect(fallback.label, 'labelled, filled buttons');
    expect(fallback.samples, hasLength(2));
  });
}
