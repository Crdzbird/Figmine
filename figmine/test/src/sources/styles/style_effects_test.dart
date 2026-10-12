import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/sources/styles/style_effects.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _rgba(double r, double g, double b, [double a = 1]) => {
  'r': r,
  'g': g,
  'b': b,
  'a': a,
};

void main() {
  final collection = StyleEffects.collect([
    (
      name: 'Elevation/1',
      type: 'EFFECT',
      description: 'Cards',
      node: {
        'effects': [
          {
            'type': 'DROP_SHADOW',
            'color': _rgba(0, 0, 0, 0.25),
            'offset': {'x': 0, 'y': 2},
            'radius': 4,
            'spread': 1,
          },
          {'type': 'LAYER_BLUR', 'radius': 8},
        ],
      },
    ),
    (
      name: 'Gradient Dark',
      type: 'FILL',
      description: '',
      node: {
        'fills': [
          {
            'type': 'GRADIENT_LINEAR',
            'gradientHandlePositions': [
              {'x': 0, 'y': 0},
              {'x': 1, 'y': 1},
            ],
            'gradientStops': [
              {'color': _rgba(0, 0, 0), 'position': 0},
              {'color': _rgba(1, 1, 1), 'position': 1},
            ],
          },
        ],
      },
    ),
    (name: 'Solid', type: 'FILL', description: '', node: <String, Object?>{}),
  ])!;

  test('effect styles become shadows and gradient fills gradients', () {
    expect(collection.tokens.map((t) => t.type), [
      TokenType.shadow,
      TokenType.gradient,
    ]);
    expect(collection.tokens.first.path, ['Elevation', '1']);
  });

  test('shadows and gradients render as const Flutter values', () {
    String code(int i) =>
        DartSource.value(collection.tokens[i].values.values.single.value);
    expect(
      code(0),
      '[BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), '
      'blurRadius: 4, spreadRadius: 1)]',
    );
    expect(
      code(1),
      'LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, '
      'colors: [Color(0xFF000000), Color(0xFFFFFFFF)], stops: [0, 1])',
    );
  });
}
