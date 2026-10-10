import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/adopt_workflow_template.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/cli/config_template.dart';
import 'package:figmine/src/cli/scaffold_command.dart';
import 'package:figmine/src/cli/tokens_workflow_template.dart';
import 'package:figmine/src/cli/workflow_template.dart';
import 'package:figmine/src/config/file_key.dart';

/// `figmine init`: writes `figmine.yaml`, the GitHub sync workflow and the
/// theme scaffold.
final class InitCommand extends Command<int> {
  /// Creates the command.
  factory() = InitCommand._;

  new _() {
    argParser
      ..addOption('file', help: 'Figma file URL or key.')
      ..addFlag(
        'workflow',
        defaultsTo: true,
        help: 'Add the GitHub sync, tokens and adopt workflows.',
      )
      ..addFlag('scaffold', defaultsTo: true, help: 'Add the theme layer.');
  }

  @override
  String get name => 'init';

  @override
  String get description =>
      'Create figmine.yaml, the sync workflow and the theme.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final key = FileKey.parse(args.option('file') ?? 'YOUR_FILE_KEY');
    final problem = args.option('file') == null ? null : FileKey.problem(key);
    if (problem != null) usageException(problem);
    await _create('figmine.yaml', ConfigTemplate.render(key));
    if (args.flag('workflow')) {
      await _create(
        '.github/workflows/figmine_sync.yaml',
        WorkflowTemplate.contents,
      );
      await _create(
        '.github/workflows/figmine_adopt.yaml',
        AdoptWorkflowTemplate.contents,
      );
      await _create(
        '.github/workflows/figmine_tokens.yaml',
        TokensWorkflowTemplate.contents,
      );
    }
    if (args.flag('scaffold')) await ScaffoldCommand.scaffold('figmine.yaml');
    return 0;
  }

  Future<void> _create(String path, String contents) async {
    final file = File(path);
    if (file.existsSync()) {
      CliSupport.log('Skipped $path, it already exists.');
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
    CliSupport.log('Created $path.');
  }
}
