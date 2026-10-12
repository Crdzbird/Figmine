import 'package:figmine/src/codegen/typography/typography_roles.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/score/scheme_values.dart';
import 'package:figmine/src/score/text_values.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:flutter_test/flutter_test.dart';

const String _scheme = '''
  static const AppColorScheme light = AppColorScheme(
    primary: AppBrand.defaultToken,
    secondary: Color(0xFF5E5E5E),
  );
  static const AppColorScheme dark = AppColorScheme(
    primary: Color(0xFFF5F5F5),
  );
''';

const String _text = '''
  static const TextStyle bodyBase = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
  );
  static const TextTheme textTheme = TextTheme(
    bodyLarge: bodyBase,
  );
''';

TextStyleToken _style(String name, double size) => TextStyleToken(
  path: name.split('/'),
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: 400,
);

void main() {
  test('reads scheme colors per mode, resolving token references', () {
    final symbols = {
      'AppBrand.defaultToken': (
        token: 'Brand/Default',
        mode: null,
        type: 'Color',
        value: 'Color(0xFF2C2C2C)',
        id: null,
      ),
    };
    final light = SchemeValues.read(
      _scheme,
      'AppColorScheme',
      symbols,
      'light',
    );
    expect(light, {'primary': 0xFF2C2C2C, 'secondary': 0xFF5E5E5E});
    final dark = SchemeValues.read(_scheme, 'AppColorScheme', symbols, 'dark');
    expect(dark, {'primary': 0xFFF5F5F5});
  });

  test('reads text roles with family and size', () {
    expect(TextValues.read(_text), {
      'bodyLarge': (family: 'Inter', size: 16.0),
    });
  });

  test('identical styles take one role, under the shortest name', () {
    final roles = TypographyRoles.match([
      _style('Single Line/Body Base', 16),
      _style('Body Base', 16),
      _style('Body Small', 14),
    ], const TypographyConfig());
    expect(roles['bodyLarge']!.name, 'Body Base');
    expect(roles['bodySmall']!.name, 'Body Small');
    expect(
      roles.values.map((s) => s.name),
      isNot(contains('Single Line/Body Base')),
    );
  });
}
