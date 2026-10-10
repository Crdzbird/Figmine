import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/preview/preview_section.dart';
import 'package:figmine/src/preview/preview_test_writer.dart';
import 'package:path/path.dart' as p;

/// `figmine preview`: renders the generated theme to light and dark PNGs,
/// and adds them to a pull request report.
final class PreviewCommand extends Command<int> {
  /// Creates the command.
  factory() = PreviewCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption('output', abbr: 'o', defaultsTo: '.figmine/preview/after')
      ..addOption('compare', help: 'Folder with earlier images to compare.')
      ..addOption('report', help: 'Markdown report to append the images to.')
      ..addOption('branch', defaultsTo: 'figmine/sync')
      ..addOption('image-url', help: 'Base URL of the image links.');
  }

  @override
  String get name => 'preview';

  @override
  String get description => 'Render the theme to images for pull requests.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final root = Directory.current.path;
    final output = args.option('output')!;
    final writer = PreviewTestWriter(
      root: root,
      output: config.output,
      project: await ProjectInfo.read(
        root,
        materialImport: config.output.materialImport,
      ),
    );
    if (!writer.ready) {
      CliSupport.log('Nothing to preview yet. Run figmine generate first.');
      return 0;
    }
    final out = Directory(p.join(root, output));
    await out.create(recursive: true);
    final error = await writer.render(out.absolute.path);
    if (error != null) {
      stderr.writeln(error);
      return 1;
    }
    CliSupport.log('Wrote light.png and dark.png to $output.');
    final report = args.option('report');
    if (report == null) return 0;
    final section = PreviewSection.markdown(
      root: root,
      after: output,
      before: args.option('compare'),
      base:
          args.option('image-url') ??
          PreviewSection.githubBase(args.option('branch')!),
    );
    await File(report).writeAsString(section, mode: FileMode.append);
    return 0;
  }
}
