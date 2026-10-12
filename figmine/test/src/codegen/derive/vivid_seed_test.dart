import 'package:figmine/src/codegen/derive/seed_scheme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

void main() {
  test('a vivid seed keeps its palette, as in the Material 3 baseline', () {
    final light = SeedScheme.derive(0xFF6750A4, dark: false);
    expect(light['primary'], 0xFF6750A4);
    expect(light['onPrimaryContainer'], 0xFF4F378A);
    final dark = SeedScheme.derive(0xFF6750A4, dark: true);
    expect(dark['onPrimary'], 0xFF381E72);
  });

  test('dark roles keep the chroma a pale dark primary cannot hold', () {
    final chroma = Hct.fromInt(0xFF6750A4).chroma;
    final dark = SeedScheme.derive(0xFFD0BCFF, dark: true, chroma: chroma);
    expect(dark['primaryContainer'], 0xFF50378A);
    final muted = SeedScheme.derive(0xFFD0BCFF, dark: true);
    expect(muted['primaryContainer'], isNot(0xFF50378A));
  });
}
