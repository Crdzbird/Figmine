import 'package:figmine/src/config/file_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(FileKey, () {
    test('extracts keys from every Figma link shape', () {
      const key = 'AbC123xyzAbC123xyz0000';
      for (final kind in ['file', 'design', 'proto', 'board', 'slides']) {
        expect(
          FileKey.parse('https://www.figma.com/$kind/$key/Name?node-id=1-2'),
          key,
        );
      }
      expect(
        FileKey.parse('https://www.figma.com/design/$key/branch/Br4nchKey99/X'),
        'Br4nchKey99',
      );
      expect(FileKey.parse('  $key '), key);
    });

    test('rejects tokens, placeholders and malformed keys', () {
      expect(FileKey.problem('AbC123xyzAbC123xyz0000'), isNull);
      final token = FileKey.problem('figd_SECRETSECRETSECRET')!;
      expect(token, contains('access token'));
      expect(token, isNot(contains('SECRET')));
      expect(FileKey.problem('figd'), contains('access token'));
      expect(FileKey.problem('YOUR_FILE_KEY'), contains('placeholder'));
      expect(FileKey.problem('abc'), contains('not a Figma file key'));
    });
  });
}
