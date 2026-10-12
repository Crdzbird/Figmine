import 'package:figmine/src/codegen/derive/feedback_lookup.dart';
import 'package:figmine/src/codegen/scheme/binding_lookup.dart';
import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/codegen/scheme/role_pairs.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

List<ColorCandidate> _pool(Map<String, int> colors) {
  var id = 0;
  final collection = TokenCollection(
    name: 'Color',
    modes: const ['Light'],
    tokens: [
      for (final e in colors.entries)
        DesignToken(
          path: e.key.split('/'),
          type: TokenType.color,
          values: {'Light': TokenValue(ColorValue.fromArgb(e.value))},
          variableId: 'V:${id++}',
        ),
    ],
  );
  return [
    for (final t in collection.tokens) (collection: collection, token: t),
  ];
}

void main() {
  test('a text token bound as a fill does not become a background', () {
    final all = _pool({'Text/Neutral/On Neutral': 0xFFF3F3F3});
    expect(
      BindingLookup.forRole('surfaceContainer', {
        'surfaceContainer': 'V:0',
      }, all),
      isNull,
    );
  });

  test('a foreground that does not read on its background is dropped', () {
    final all = _pool({'Bg/Inverse': 0xFF1E1E1E, 'Text/Default': 0xFF1E1E1E});
    final kept = RolePairs.consistent({
      'inverseSurface': all[0],
      'onInverseSurface': all[1],
    });
    expect(kept.keys, ['inverseSurface']);
  });

  test('feedback aliases match whole words, with a fitting hue', () {
    final all = _pool({
      'Text/Required/Default': 0xFF2C2C2C,
      'Text/Danger/Default': 0xFF900B09,
      'Text/Positive/Brand': 0xFF1E33B1,
    });
    ColorCandidate? find(String name) => FeedbackLookup.find(
      name,
      variables: const {},
      all: all,
      ramp: null,
      uses: const {},
      surface: 0xFFFFFFFF,
      brand: const [0xFF2C2C2C],
    );
    expect(find('error')!.token.name, 'Text/Danger/Default');
    expect(find('success'), isNull);
  });
}
