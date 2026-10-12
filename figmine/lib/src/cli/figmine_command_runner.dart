import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/commands/adopt_command.dart';
import 'package:figmine/src/cli/commands/check_command.dart';
import 'package:figmine/src/cli/commands/comment_command.dart';
import 'package:figmine/src/cli/commands/doctor_command.dart';
import 'package:figmine/src/cli/commands/exporter_command.dart';
import 'package:figmine/src/cli/commands/generate_command.dart';
import 'package:figmine/src/cli/commands/init_command.dart';
import 'package:figmine/src/cli/commands/preview_command.dart';
import 'package:figmine/src/cli/commands/relay_command.dart';
import 'package:figmine/src/cli/commands/scaffold_command.dart';
import 'package:figmine/src/cli/commands/score_command.dart';
import 'package:figmine/src/cli/commands/webhook_command.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_rate_limit.dart';

/// Entry point of the `figmine` command line tool.
final class FigmineCommandRunner extends CommandRunner<int> {
  /// Creates the runner with every command.
  factory() = FigmineCommandRunner._;

  new _() : super('figmine', 'Sync Figma design tokens into Flutter code.') {
    addCommand(InitCommand());
    addCommand(GenerateCommand());
    addCommand(CheckCommand());
    addCommand(ScaffoldCommand());
    addCommand(DoctorCommand());
    addCommand(WebhookCommand());
    addCommand(CommentCommand());
    addCommand(ExporterCommand());
    addCommand(RelayCommand());
    addCommand(PreviewCommand());
    addCommand(AdoptCommand());
    addCommand(ScoreCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await super.run(args) ?? 0;
    } on UsageException catch (error) {
      stderr.writeln(error);
      return 64;
    } on ConfigException catch (error) {
      stderr.writeln(error);
      return 78;
    } on FigmaException catch (error) {
      stderr.writeln(error);
      return 1;
    } on FigmaRateLimit catch (error) {
      stderr.writeln(error);
      return 75;
    }
  }
}
