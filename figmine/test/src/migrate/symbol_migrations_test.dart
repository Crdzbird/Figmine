import 'dart:io';

import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/migrate/code_migrator.dart';
import 'package:figmine/src/migrate/symbol_migrations.dart';
import 'package:flutter_test/flutter_test.dart';

LockSymbol _s(String token, {String? id, String? mode}) => (
  token: token,
  mode: mode,
  type: 'Color',
  value: 'Color(0xFF000000)',
  id: id,
);

void main() {
  test('matches vanished symbols by token, then by variable id', () {
    final changes = SymbolMigrations.between(
      {
        'AppOld.moved': _s('C/a'),
        'AppA.renamed': _s('C/b', id: 'V:1', mode: 'Light'),
        'AppA.gone': _s('C/c', id: 'V:2'),
        'AppA.same': _s('C/d'),
      },
      {
        'AppNew.moved': _s('C/a'),
        'AppA.newName': _s('C/b2', id: 'V:1', mode: 'Light'),
        'AppA.same': _s('C/d'),
      },
    );
    expect(changes.renamed, {
      'AppOld.moved': 'AppNew.moved',
      'AppA.renamed': 'AppA.newName',
    });
    expect(changes.removed.keys, ['AppA.gone']);
  });

  test(
    'finds and rewrites whole symbols only, outside generated code',
    () async {
      final root = await Directory.systemTemp.createTemp('figmine_migrate');
      addTearDown(() async => await root.delete(recursive: true));
      Future<void> write(String path, String text) async {
        final file = File('${root.path}/$path');
        await file.create(recursive: true);
        await file.writeAsString(text);
      }

      await write(
        'lib/a.dart',
        'final x = AppA.b; final y = AppA.bc; final z = XAppA.b;',
      );
      await write('test/a_test.dart', 'final x = tokens.AppA.b;');
      await write('lib/theme/tokens/a.g.dart', 'final x = AppA.b;');
      await write('lib/theme/tokens/hand.dart', 'final x = AppA.b;');
      const migrator = CodeMigrator(root: '', output: 'lib/theme/tokens');
      final scoped = CodeMigrator(root: root.path, output: migrator.output);
      expect((await scoped.usages(['AppA.b']))['AppA.b'], {
        'lib/a.dart',
        'test/a_test.dart',
      });
      final changed = await scoped.rewrite({'AppA.b': 'AppB.b'});
      expect(changed, {'lib/a.dart', 'test/a_test.dart'});
      expect(
        await File('${root.path}/lib/a.dart').readAsString(),
        'final x = AppB.b; final y = AppA.bc; final z = XAppA.b;',
      );
      expect(
        await File('${root.path}/lib/theme/tokens/a.g.dart').readAsString(),
        contains('AppA.b'),
      );
    },
  );
}
