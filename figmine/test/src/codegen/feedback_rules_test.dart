import 'package:figmine/src/codegen/color_candidates.dart';
import 'package:figmine/src/codegen/feedback_lookup.dart';
import 'package:figmine/src/codegen/role_ramps.dart';
import 'package:figmine/src/codegen/step_assignment.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

List<ColorCandidate> _pool(Map<String, int> colors) {
  final collection = TokenCollection(
    name: 'colors',
    modes: const ['Value'],
    tokens: [
      for (final e in colors.entries)
        DesignToken(
          path: e.key.split('/'),
          type: TokenType.color,
          values: {'Value': TokenValue(ColorValue.fromArgb(e.value))},
        ),
    ],
  );
  return [
    for (final t in collection.tokens) (collection: collection, token: t),
  ];
}

ColorCandidate? _find(String name, List<ColorCandidate> all) =>
    FeedbackLookup.find(
      name,
      variables: const {},
      all: all,
      ramp: RoleRamps.find(all)[name],
      uses: const {},
      surface: 0xFFFFFFFF,
      brand: const [0xFF3567F6],
    );

Map<String, int> _scale(String name, double hue) => {
  for (final (step, tone) in [(10, 95), (30, 80), (50, 60), (70, 40), (90, 20)])
    '$name/$step': TonalPalette.of(hue, 48).get(tone),
};

void main() {
  test('feedback roles take the lightest step that reads as text', () {
    final picked = _find('success', _pool(_scale('success', 145)));
    expect(picked!.token.name, 'success/70');
  });

  test('without a scale, readable text tokens off the brand hue win', () {
    final all = _pool({
      'fills/info/regular': 0xFFD7EEF9,
      'text/info-2/strong': 0xFF2A4DD3,
      'text/info-1/strong': 0xFF297396,
    });
    expect(_find('info', all)!.token.name, 'text/info-1/strong');
  });

  test('a leaf named after a role in a usage group is not explicit', () {
    final all = _pool({'border/feedback/error': 0xFFD40E14});
    expect(ColorCandidates.byLeaf(all, 'error'), isNull);
    expect(
      ColorCandidates.byLeaf(_pool({'error': 0xFFD40E14}), 'error'),
      isNotNull,
    );
  });

  test('each scale step stands for one derived tone', () {
    final ramps = RoleRamps.find(_pool(_scale('neutral', 0)));
    final steps = StepAssignment.assign({
      'surfaceContainerLow': TonalPalette.of(0, 0).get(96),
      'surfaceContainer': TonalPalette.of(0, 0).get(94),
    }, ramps);
    expect(steps['neutral'], hasLength(1));
    expect(steps['neutral']!.values.single.token.name, 'neutral/10');
  });
}
