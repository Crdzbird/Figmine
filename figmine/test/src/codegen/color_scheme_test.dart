import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/seed_scheme.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';

List<SchemeField> _fields(SchemeConfig scheme) => SchemeFields.resolve(
  matcher: SchemeMatcher(sampleTokens.collections, scheme),
  index: TokenIndex(
    collections: sampleTokens.collections,
    prefix: 'App',
    config: const TokensConfig(),
  ),
  tokens: const TokensConfig(),
);

void main() {
  group(SchemeFields, () {
    test('references matched roles per mode and derives the rest', () {
      final fields = {for (final f in _fields(const SchemeConfig())) f.name: f};
      expect(fields.keys.take(46), MaterialRoles.colorScheme);
      expect(fields['primary']!.light.code, 'AppSemanticLight.primary');
      expect(fields['primary']!.dark.code, 'AppSemanticDark.primary');
      expect(fields['secondary']!.light.code, startsWith('Color(0x'));
      expect(fields['secondary']!.doc, contains('derived from `primary`'));
    });

    test('adds every other token of the scheme collection', () {
      final fields = _fields(const SchemeConfig(collection: 'Semantic'));
      final success = fields.firstWhere((f) => f.name == 'success');
      expect(success.dark.code, 'AppSemanticDark.success');
    });

    test('adds configured extras and rejects unknown roles', () {
      final fields = _fields(
        const SchemeConfig(extra: {'brand': 'palette/blue/500'}),
      );
      final brand = fields.firstWhere((f) => f.name == 'brand');
      expect(brand.light.code, 'AppPrimitivesPaletteBlue.v500');
      expect(fields.map((f) => f.name), containsAll(['success', 'onSuccess']));
      expect(
        () => _fields(const SchemeConfig(roles: {'brand': 'primary'})),
        throwsA(isA<ConfigException>()),
      );
      expect(
        () => _fields(const SchemeConfig(seed: 'missing')),
        throwsA(isA<ConfigException>()),
      );
    });
  });

  group(SeedScheme, () {
    test('matches ColorScheme.fromSeed for every role', () {
      for (final brightness in Brightness.values) {
        const seed = Color(0xFF3567F6);
        final flutter = ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
        );
        final derived = SeedScheme.derive(
          seed.toARGB32(),
          dark: brightness == Brightness.dark,
        );
        expect(derived['primary'], flutter.primary.toARGB32());
        expect(
          derived['onInverseSurface'],
          flutter.onInverseSurface.toARGB32(),
        );
        expect(
          derived['surfaceContainerHighest'],
          flutter.surfaceContainerHighest.toARGB32(),
        );
        expect(
          derived['onTertiaryFixedVariant'],
          flutter.onTertiaryFixedVariant.toARGB32(),
        );
        expect(derived['surfaceTint'], flutter.surfaceTint.toARGB32());
        expect(derived.length, MaterialRoles.colorScheme.length);
      }
    });
  });
}
