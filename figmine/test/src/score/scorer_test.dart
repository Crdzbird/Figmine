import 'dart:io';

import 'package:figmine/src/score/score_item.dart';
import 'package:figmine/src/score/score_reference.dart';
import 'package:figmine/src/score/score_report.dart';
import 'package:figmine/src/score/scorer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('grades colors, numbers and text against a YAML reference', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_score');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'reference.yaml');
    await File(path).writeAsString('''
colors:
  primary: {light: "#2C2C2C", dark: "#F5F5F5"}
  error: "#900B09"
components:
  buttonRadius: 8
  inputHeight: 40
typography:
  bodyLarge: {family: Inter, size: 16}
''');
    final reference = await ScoreReference.load(path);
    const actual = (
      light: {'primary': 0xFF2C2C2C, 'error': 0xFF8F0B0A},
      dark: {'primary': 0xFF1E1E1E},
      components: {'buttonRadius': 8.0, 'inputHeight': 48.0},
      text: {'bodyLarge': (family: 'Inter', size: 14.0)},
    );
    final items = Scorer.grade(reference, actual);
    Grade grade(String name) =>
        items.firstWhere((i) => '${i.section}.${i.name}' == name).grade;
    expect(grade('colors.primary'), Grade.match);
    expect(grade('colors.error'), Grade.match);
    expect(grade('dark colors.primary'), Grade.off);
    expect(grade('components.buttonRadius'), Grade.match);
    expect(grade('components.inputHeight'), Grade.off);
    expect(grade('typography.bodyLarge'), Grade.close);
    expect(ScoreReport.total(items), closeTo(350 / 6, 0.1));
    expect(ScoreReport.lines(items).last, 'Score: 58.3% of 6 values.');
    expect(
      ScoreReport.markdown(items, 'the screens alone'),
      contains('| components.inputHeight | `40` | `48` | off |'),
    );
  });
}
