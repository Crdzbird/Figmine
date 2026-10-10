import 'package:figmine/src/adopt/adopt_rewriter.dart';
import 'package:figmine/src/adopt/literal_scanner.dart';
import 'package:figmine/src/adopt/token_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const String _source = '''
import 'package:flutter/material.dart';

final a = Container(color: const Color(0xFF2C2C2C));
final b = Text('x', style: TextStyle(color: Color(0xFF2C2C2C)));
final c = Divider(color: Color(0xFF123456));
''';

void main() {
  final catalog = TokenCatalog(
    {
      'AppTextBrand.defaultToken': (
        token: 'Color/Text/Brand/Default',
        mode: 'Light',
        type: 'Color',
        value: 'Color(0xFF2C2C2C)',
        id: null,
      ),
      'AppBackgroundBrand.defaultToken': (
        token: 'Color/Background/Brand/Default',
        mode: 'Light',
        type: 'Color',
        value: 'Color(0xFF2C2C2C)',
        id: null,
      ),
      'AppBackgroundBrandDark.defaultToken': (
        token: 'Color/Background/Brand/Default',
        mode: 'Dark',
        type: 'Color',
        value: 'Color(0xFF2C2C2C)',
        id: null,
      ),
    },
    roles: {
      0xFF2C2C2C: ['primary', 'onSurface'],
    },
  );
  final found = [
    for (final l in LiteralScanner.scan(_source, 'lib/a.dart'))
      catalog.suggest(l),
  ];

  test('colors take the token and role meant for their use', () {
    expect(found[0].constant, 'AppBackgroundBrand.defaultToken');
    expect(found[0].themed, 'context.colors.primary');
    expect(found[1].constant, 'AppTextBrand.defaultToken');
    expect(found[1].themed, 'context.colors.onSurface');
    expect(found[2].constant, isNull);
  });

  test('applying drops the const before a token and adds the import', () {
    final result = AdoptRewriter.apply(
      _source,
      found,
      'package:app/theme/tokens/figmine.g.dart',
    );
    expect(
      result,
      startsWith(
        "import 'package:app/theme/tokens/figmine.g.dart';\nimport 'package:flutter",
      ),
    );
    expect(
      result,
      contains('Container(color: AppBackgroundBrand.defaultToken)'),
    );
    expect(result, contains('TextStyle(color: AppTextBrand.defaultToken)'));
    expect(result, contains('Color(0xFF123456)'));
  });
}
