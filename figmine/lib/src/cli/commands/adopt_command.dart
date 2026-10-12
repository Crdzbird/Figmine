import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/adopt/added_lines.dart';
import 'package:figmine/src/adopt/adopt_output.dart';
import 'package:figmine/src/adopt/adopt_project.dart';
import 'package:figmine/src/adopt/adopt_report.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/config/project_info.dart';

/// `figmine adopt`: finds hard coded colors, spacings and radii that match
/// tokens, and replaces them.
final class AdoptCommand extends Command<int> {
  /// Creates the command.
  factory() = AdoptCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addMultiOption('path', defaultsTo: ['lib'], help: 'Folders to scan.')
      ..addOption('since', help: 'Only lines added since this git ref.')
      ..addOption('report', help: 'Append a Markdown section to this file.')
      ..addFlag('apply', negatable: false, help: 'Replace with tokens.')
      ..addFlag(
        'set-exit-if-found',
        negatable: false,
        help: 'Exit with code 1 when hard coded values remain.',
      );
  }

  @override
  String get name => 'adopt';

  @override
  String get description =>
      'Find hard coded design values that match tokens, offline.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final root = Directory.current.path;
    final paths = args.multiOption('path');
    final project = AdoptProject(root, config);
    var files = await project.scan(paths);
    final since = args.option('since');
    if (since != null) {
      files = AddedLines.keep(
        files,
        await AddedLines.since(root, since, paths),
      );
    }
    AdoptReport.lines(files).forEach(CliSupport.log);
    if (Platform.environment['GITHUB_ACTIONS'] == 'true') {
      AdoptOutput.annotations(files).forEach(stdout.writeln);
    }
    final report = args.option('report');
    if (report != null) {
      await File(report)
          .writeAsString(AdoptOutput.markdown(files), mode: FileMode.append);
    }
    if (args.flag('apply')) {
      final package = (await ProjectInfo.read(root)).packageName;
      if (package == null) {
        throw const ConfigException('pubspec.yaml has no package name.');
      }
      for (final path in await project.apply(files, package)) {
        CliSupport.log('Updated $path.');
      }
    }
    final remaining = files.isNotEmpty && !args.flag('apply');
    return remaining && args.flag('set-exit-if-found') ? 1 : 0;
  }
}
