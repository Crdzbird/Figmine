import 'dart:convert';

import 'package:figmine/src/lock/diff_report.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/lock_json.dart';
import 'package:figmine/src/lock/token_diff.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';

LockFile _lock(
  String version, {
  Map<String, String> tokens = const {},
  Map<String, String> typography = const {},
  Map<String, String> icons = const {},
}) => LockFile(
  fileKey: 'KEY',
  version: version,
  lastModified: 'today',
  tokens: tokens,
  typography: typography,
  icons: icons,
);

void main() {
  final before = _lock(
    '1',
    tokens: {'C/a': '0xFF000000', 'C/b': 'x'},
    typography: {'Body': 'Inter 16 w400'},
    icons: {'home': 'h1', 'old': 'o1'},
  );
  final after = _lock(
    '2',
    tokens: {'C/a': '0xFFFFFFFF', 'C/c': 'x'},
    typography: {'Body': 'Inter 16 w500'},
    icons: {'home': 'h2', 'new': 'n1'},
  );

  group(TokenDiff, () {
    test('lists added, removed and changed names per kind', () {
      final diff = TokenDiff.between(before, after);
      expect(diff.tokens.added, ['C/c']);
      expect(diff.tokens.removed, ['C/b']);
      expect(diff.tokens.changed, ['C/a']);
      expect(diff.typography.changed, ['Body']);
      expect(diff.icons.added, ['new']);
      expect(diff.isEmpty, isFalse);
      expect(TokenDiff.between(after, after).isEmpty, isTrue);
    });
  });

  group(LockFile, () {
    test('snapshots modes, numbers, typography and icons', () {
      final lock = LockFile.of('KEY', sampleTokens);
      expect(lock.tokens['Primitives/radius/m'], '12');
      expect(
        lock.tokens['Semantic/primary'],
        'Light=0xFF0000FF Dark=0xFFFFFFFF',
      );
      expect(lock.typography['Display/Large'], 'Inter 32 w700 h1.250');
      expect(lock.icons.keys, ['home']);
    });

    test('round trips through JSON and reads the legacy colors key', () {
      final restored = LockJson.decode(
        Map<String, Object?>.from(jsonDecode(LockJson.encode(after)) as Map),
      );
      expect(restored.tokens, after.tokens);
      expect(restored.typography, after.typography);
      final legacy = LockJson.decode({
        'colors': {'a': 'b'},
      });
      expect(legacy.tokens, {'a': 'b'});
    });
  });

  group(DiffReport, () {
    test('renders tables for tokens and typography, lists for icons', () {
      final report = DiffReport.markdown(
        fileName: 'DS',
        previous: before,
        next: after,
        diff: TokenDiff.between(before, after),
      );
      expect(report, contains('### Tokens (3)'));
      expect(report, contains('| `C/a` | changed | 0xFF000000 | 0xFFFFFFFF |'));
      expect(report, contains('### Typography (1)'));
      expect(report, contains('- Added (1): `new`'));
    });
  });
}
