import 'package:figmine/src/codegen/typography/typography_roles.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:flutter_test/flutter_test.dart';

TextStyleToken _style(
  String name, {
  String family = 'Inter',
  bool italic = false,
  String? decoration,
}) => TextStyleToken(
  path: name.split('/'),
  fontFamily: family,
  fontSize: 16,
  fontWeight: 400,
  italic: italic,
  decoration: decoration,
);

void main() {
  test('plain styles fill roles before italic, link, code or private', () {
    final roles = TypographyRoles.match([
      _style('.Utilities/Notes'),
      _style('Body Emphasis', italic: true),
      _style('Body Link', decoration: 'underline'),
      _style('Body Code', family: 'Roboto Mono'),
      _style('Body Base'),
    ], const TypographyConfig());
    expect(roles['bodyLarge']!.name, 'Body Base');
    expect(
      roles.values.map((s) => s.name),
      isNot(contains('.Utilities/Notes')),
    );
  });
}
