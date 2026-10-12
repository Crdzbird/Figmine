import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/score/generated_snapshot.dart';
import 'package:figmine/src/score/inferred_snapshot.dart';
import 'package:figmine/src/score/score_reference.dart';
import 'package:figmine/src/score/score_report.dart';
import 'package:figmine/src/score/scorer.dart';

/// `figmine score`: grades the generated or the inferred theme against a
/// reference, offline.
final class ScoreCommand extends Command<int> {
  /// Creates the command.
  factory() = ScoreCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption('reference', mandatory: true, help: 'Expected values.')
      ..addFlag(
        'inferred',
        negatable: false,
        help: 'Grade what the screens alone give, ignoring tokens.',
      )
      ..addOption('report', help: 'Write a Markdown scorecard here.')
      ..addOption('min', help: 'Exit with code 1 below this percentage.');
  }

  @override
  String get name => 'score';

  @override
  String get description =>
      'Grade the theme against reference values, offline.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final root = Directory.current.path;
    final inferred = args.flag('inferred');
    final actual = inferred
        ? await InferredSnapshot.read(root, config)
        : await GeneratedSnapshot.read(root, config);
    final reference = await ScoreReference.load(args.option('reference')!);
    final items = Scorer.grade(reference, actual);
    ScoreReport.lines(items).forEach(CliSupport.log);
    final report = args.option('report');
    if (report != null) {
      final source = inferred ? 'the screens alone' : 'the generated theme';
      await File(report).writeAsString(ScoreReport.markdown(items, source));
    }
    final min = double.tryParse(args.option('min') ?? '');
    return min != null && ScoreReport.total(items) < min ? 1 : 0;
  }
}
