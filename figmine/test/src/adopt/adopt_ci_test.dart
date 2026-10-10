import 'package:figmine/src/adopt/added_lines.dart';
import 'package:figmine/src/adopt/adopt_output.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/cli/adopt_workflow_template.dart';
import 'package:figmine/src/cli/workflow_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const String _diff = '''
diff --git a/lib/a.dart b/lib/a.dart
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -10,0 +11,2 @@ class A {
+  final c = Color(0xFF2C2C2C);
+  final d = 1;
@@ -20 +22 @@ class A {
-  old
+  new
''';

void main() {
  final suggestion = (
    literal: (
      path: 'lib/a.dart',
      offset: 0,
      length: 17,
      line: 11,
      column: 13,
      kind: LiteralKind.color,
      text: 'Color(0xFF2C2C2C)',
      value: 0xFF2C2C2C,
      owner: null,
      property: 'c',
    ),
    constant: 'AppBrand.defaultToken',
    others: <String>[],
    themed: 'context.colors.primary',
  );
  final files = [
    (path: 'lib/a.dart', source: '', found: [suggestion]),
  ];

  test('reads the lines a branch adds', () {
    final added = AddedLines.parse(_diff);
    expect(added['lib/a.dart'], {11, 12, 22});
    expect(AddedLines.keep(files, added), hasLength(1));
    expect(
      AddedLines.keep(files, {
        'lib/a.dart': {30},
      }),
      isEmpty,
    );
  });

  test('writes GitHub annotations and a Markdown section', () {
    expect(
      AdoptOutput.annotations(files).single,
      startsWith('::warning file=lib/a.dart,line=11,col=13,'),
    );
    final markdown = AdoptOutput.markdown(files);
    expect(markdown, contains('1 hard coded value in the app'));
    expect(markdown, contains('`lib/a.dart:11`'));
  });

  test('the workflows are valid YAML and run adopt', () {
    final sync = loadYaml(WorkflowTemplate.contents) as Map;
    final check = loadYaml(AdoptWorkflowTemplate.contents) as Map;
    expect(WorkflowTemplate.contents, contains('figmine adopt --report'));
    expect((check['on'] as Map).keys, ['pull_request']);
    expect(sync['jobs'], isA<Map<dynamic, dynamic>>());
    expect(AdoptWorkflowTemplate.contents, contains('--since'));
  });
}
