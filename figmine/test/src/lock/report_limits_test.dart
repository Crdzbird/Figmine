import 'dart:io';

import 'package:figmine/src/lock/diff_report.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/token_diff.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/pipeline/stale_files.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('large reports list changes first and stay under the PR limit', () {
    final next = LockFile(
      fileKey: 'K',
      version: '2',
      lastModified: '',
      tokens: {
        for (var i = 0; i < 3000; i++)
          'Collection/a/very/long/token/name/$i': '$i',
        'Collection/changed': 'new',
      },
    );
    const before = LockFile(
      fileKey: 'K',
      version: '1',
      lastModified: '',
      tokens: {'Collection/changed': 'old'},
    );
    final report = DiffReport.markdown(
      fileName: 'DS',
      previous: before,
      next: next,
      diff: TokenDiff.between(before, next),
    );
    expect(report.length, lessThan(60100));
    expect(report, contains('| `Collection/changed` | changed | old | new |'));
    expect(report, contains('| and 2901 more | | | |'));
  });

  test('stale generated files are removed, others are kept', () async {
    final root = await Directory.systemTemp.createTemp('figmine_stale');
    addTearDown(() async => await root.delete(recursive: true));
    for (final name in ['keep.g.dart', 'old.g.dart', 'notes.dart']) {
      await File('${root.path}/out/$name').create(recursive: true);
    }
    final deleted = await StaleFiles.prune(root.path, 'out', {
      'out/keep.g.dart',
    });
    expect(deleted, ['out/old.g.dart']);
    expect(File('${root.path}/out/notes.dart').existsSync(), isTrue);
  });

  test('only true reserved words are renamed', () {
    expect(DartIdentifier.camel(['base']), 'base');
    expect(DartIdentifier.camel(['type']), 'type');
    expect(DartIdentifier.camel(['default']), 'defaultToken');
  });
}
