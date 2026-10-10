import 'package:figmine/src/inference/typography_inferrer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rare large text fills display, line height variants merge', () {
    final styles = TypographyInferrer.infer([
      (
        family: 'Inter',
        size: 16,
        weight: 400,
        height: 1.4,
        letterSpacing: null,
        characters: 9000,
        layers: 300,
      ),
      (
        family: 'Inter',
        size: 16,
        weight: 400,
        height: 1.0,
        letterSpacing: null,
        characters: 3000,
        layers: 90,
      ),
      (
        family: 'Inter',
        size: 14,
        weight: 400,
        height: 1.4,
        letterSpacing: null,
        characters: 2000,
        layers: 80,
      ),
      (
        family: 'Inter',
        size: 72,
        weight: 700,
        height: 1.2,
        letterSpacing: null,
        characters: 20,
        layers: 3,
      ),
    ]);
    final roles = {for (final s in styles) s.name: s};
    expect(roles['displayLarge']!.fontSize, 72);
    expect(roles['bodyLarge']!.height, 1.4);
    expect(roles['bodyMedium']!.fontSize, 14);
  });
}
