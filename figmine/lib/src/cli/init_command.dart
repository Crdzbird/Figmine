import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/cli/config_template.dart';
import 'package:figmine/src/cli/init_terminal.dart';
import 'package:figmine/src/cli/scaffold_command.dart';
import 'package:figmine/src/cli/workflow_files.dart';
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
      ..addFlag('scaffold', defaultsTo: true, help: 'Add the theme layer.')
      ..addFlag(
        'interactive',
        defaultsTo: stdin.hasTerminal,
        help: 'Ask for the file and settings when --file is not given.',
      );
  }

  @override
  String get name => 'init';

  @override
  String get description =>
      'Create figmine.yaml, the sync workflow and the theme.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final file = args.option('file');
    final ask = file == null && args.flag('interactive');
    final answers = ask ? await InitTerminal.ask() : null;
    final key = answers?.key ?? FileKey.parse(file ?? 'YOUR_FILE_KEY');
    final problem = file == null ? null : FileKey.problem(key);
    if (problem != null) usageException(problem);
    await _create(
      'figmine.yaml',
      ConfigTemplate.render(
        key,
        source: answers?.source ?? 'auto',
        inference: (answers?.screens ?? true) ? 'auto' : 'off',
        prefix: answers?.prefix ?? 'App',
      ),
    );
    if (answers?.workflows ?? args.flag('workflow')) {
      for (final (path, contents) in WorkflowFiles.all) {
        await _create(path, contents);
      }
    }
    if (args.flag('scaffold')) await ScaffoldCommand.scaffold('figmine.yaml');
    if (answers?.source == 'file') {
      CliSupport.log(
        'Next: run figmine exporter, export design-tokens.json from Figma '
        'into the project, then figmine generate --offline.',
      );
    }
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
