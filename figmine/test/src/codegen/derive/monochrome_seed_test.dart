import 'package:figmine/src/codegen/derive/seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gray seeds match the monochrome variant', () {
    for (final brightness in Brightness.values) {
      const seed = Color(0xFF2C2C2C);
      final flutter = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      );
      final derived = SeedScheme.derive(
        seed.toARGB32(),
        dark: brightness == Brightness.dark,
      );
      expect(derived['secondary'], flutter.secondary.toARGB32());
      expect(derived['tertiary'], flutter.tertiary.toARGB32());
      expect(derived['outlineVariant'], flutter.outlineVariant.toARGB32());
    }
  });
}
