import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/scaffold/scaffold_context.dart';
import 'package:figmine/src/scaffold/scaffold_writer.dart';

/// `figmine scaffold`: writes the theme layer that consumes the tokens.
final class ScaffoldCommand extends Command<int> {
  /// Creates the command.
  factory() = ScaffoldCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addFlag(
        'force',
        negatable: false,
        help: 'Overwrite existing theme files with the current templates.',
      );
  }

  @override
  String get name => 'scaffold';

  @override
  String get description =>
      'Create the theme class and component themes. Keeps existing files '
      'unless --force is given.';

  @override
  Future<int> run() async {
    final args = argResults!;
    await scaffold(args.option('config')!, force: args.flag('force'));
    return 0;
  }

  /// Writes the scaffold for the configuration at [configPath].
  static Future<void> scaffold(String configPath, {bool force = false}) async {
    final config = await ConfigLoader.load(configPath);
    final root = Directory.current.path;
    final files = ScaffoldWriter.files(
      ScaffoldContext(
        output: config.output,
        project: await ProjectInfo.read(
          root,
          materialImport: config.output.materialImport,
        ),
      ),
    );
    final project = ProjectFiles(root);
    if (force) await project.writeAll(files);
    final written = force
        ? [for (final f in files) f.path]
        : await project.writeMissing(files);
    final problem = await project.formatAll(written);
    if (problem != null) CliSupport.log('dart format failed: $problem');
    for (final file in files) {
      final verb = written.contains(file.path) ? 'Created' : 'Kept';
      CliSupport.log('$verb ${file.path}.');
    }
  }
}
