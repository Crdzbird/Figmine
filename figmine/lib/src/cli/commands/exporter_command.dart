import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/cli/templates/package_templates.dart';
import 'package:path/path.dart' as p;

/// `figmine exporter`: writes the Figma plugin that exports variables and
/// text styles to a design token file figmine reads.
final class ExporterCommand extends Command<int> {
  /// Creates the command.
  factory() = ExporterCommand._;

  new _() {
    argParser.addOption('output', abbr: 'o', defaultsTo: 'figma_exporter');
  }

  static const List<String> _files = ['manifest.json', 'code.js', 'ui.html'];

  @override
  String get name => 'exporter';

  @override
  String get description =>
      'Write the figmine exporter plugin for Figma desktop.';

  @override
  Future<int> run() async {
    final output = Directory(argResults!.option('output')!);
    await PackageTemplates.copy('exporter', _files, output);
    CliSupport.log(
      'Wrote the plugin to ${output.path}. In Figma desktop: Plugins, '
      'Development, Import plugin from manifest, then pick '
      '${p.join(output.path, 'manifest.json')}. Run it in the design file '
      'and save design-tokens.json into the project.',
    );
    return 0;
  }
}
