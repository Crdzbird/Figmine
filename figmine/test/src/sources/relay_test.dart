import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final hasNode = Process.runSync('which', ['node']).exitCode == 0;

  test('the relay checks the passcode and dispatches to GitHub', () async {
    final run = await Process.run('node', ['tool/relay_check.mjs']);
    expect(run.exitCode, 0, reason: '${run.stderr}');
    expect('${run.stdout}', contains('relay ok'));
  }, skip: hasNode ? false : 'node is not installed');
}
