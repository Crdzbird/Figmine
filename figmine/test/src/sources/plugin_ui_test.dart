import 'dart:io';

import 'package:figmine/src/cli/tokens_workflow_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final hasNode = Process.runSync('which', ['node']).exitCode == 0;

  test(
    'the plugin pushes changed tokens to the figmine/tokens branch',
    () async {
      final run = await Process.run('node', ['tool/plugin_ui_check.mjs']);
      expect(run.exitCode, 0, reason: '${run.stderr}');
      expect('${run.stdout}', contains('plugin ui ok'));
    },
    skip: hasNode ? false : 'node is not installed',
  );

  test('the tokens workflow runs on the plugin branch', () {
    final workflow = loadYaml(TokensWorkflowTemplate.contents) as YamlMap;
    final on = workflow['on'] as YamlMap;
    expect((on['push'] as YamlMap)['branches'], ['figmine/tokens']);
    expect(TokensWorkflowTemplate.contents, contains('generate --offline'));
    expect(TokensWorkflowTemplate.contents, contains('gh pr create'));
  });
}
