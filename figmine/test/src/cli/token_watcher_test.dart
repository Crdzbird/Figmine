import 'dart:async';
import 'dart:io';

import 'package:figmine/src/cli/token_watcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('reruns after a watched file changes, and survives failures', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_watch');
    addTearDown(() => dir.delete(recursive: true));
    final tokens = File(p.join(dir.path, 'tokens.json'));
    await tokens.writeAsString('{}');
    final other = File(p.join(dir.path, 'notes.txt'));
    final stop = Completer<void>();
    final logs = <String>[];
    var runs = 0;
    final watching = TokenWatcher.watch(
      [tokens.path],
      () async {
        runs++;
        if (runs == 2) throw const FormatException('half saved');
      },
      log: logs.add,
      until: stop.future,
      delay: const Duration(milliseconds: 50),
    );
    Future<void> waitFor(int count) async {
      for (var i = 0; i < 100 && runs < count; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }

    await waitFor(1);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await other.writeAsString('ignored');
    await tokens.writeAsString('{"a": 1}');
    await waitFor(2);
    await tokens.writeAsString('{"a": 2}');
    await waitFor(3);
    stop.complete();
    await watching;
    expect(runs, 3);
    expect(logs, contains(startsWith('Sync failed: FormatException')));
    expect(logs, contains(startsWith('Watching')));
  });
}
