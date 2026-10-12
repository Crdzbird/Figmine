import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/config/output_layout.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

TokenCollection _collection(String name, TokenType type) => TokenCollection(
  name: name,
  modes: const ['Value'],
  tokens: [
    DesignToken(
      path: const ['a'],
      type: type,
      values: {
        'Value': TokenValue(
          type == TokenType.color ? const ColorValue(r: 0, g: 0, b: 0) : 1.0,
        ),
      },
    ),
  ],
);

final List<TokenCollection> _tui = [
  _collection('ui/colors', TokenType.color),
  _collection('_core/colors', TokenType.color),
  _collection('_brand-colors', TokenType.color),
  _collection('_core/units', TokenType.number),
  _collection('ui/typography', TokenType.number),
  _collection('Units', TokenType.number),
  _collection('Semantic', TokenType.color),
  _collection('Spacing scale', TokenType.number),
  _collection('Inferred colors', TokenType.color),
];

List<String> _paths(OutputLayout layout) {
  final files = FileLayout(layout);
  return [for (final c in _tui) files.collection(c)];
}

void main() {
  test('domain layout sorts collections by name, then by token type', () {
    expect(_paths(OutputLayout.domain), [
      'color/ui.g.dart',
      'color/core.g.dart',
      'color/brand.g.dart',
      'units/core.g.dart',
      'typography/ui.g.dart',
      'units/units.g.dart',
      'color/semantic.g.dart',
      'units/spacing_scale.g.dart',
      'color/inferred.g.dart',
    ]);
    final files = FileLayout();
    expect(files.fixed(FixedFile.colorScheme), 'color/color_scheme.g.dart');
    expect(files.fixed(FixedFile.textStyles), 'typography/text_styles.g.dart');
  });

  test('figma layout mirrors collection names', () {
    expect(_paths(OutputLayout.figma), [
      'figma/ui/colors.g.dart',
      'figma/core/colors.g.dart',
      'figma/brand_colors.g.dart',
      'figma/core/units.g.dart',
      'figma/ui/typography.g.dart',
      'figma/units.g.dart',
      'figma/semantic.g.dart',
      'figma/spacing_scale.g.dart',
      'inferred/colors.g.dart',
    ]);
    final files = FileLayout(OutputLayout.figma);
    expect(files.fixed(FixedFile.colorScheme), 'theme/color_scheme.g.dart');
    expect(files.fixed(FixedFile.barrel), 'figmine.g.dart');
  });
}
