import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:http/http.dart' as http;

/// `figmine check`: reports whether the Figma file moved past the lock.
final class CheckCommand extends Command<int> {
  /// Creates the command.
  factory() = CheckCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addFlag(
        'exit-code',
        help: 'Exit with code 1 when Figma has a newer version.',
      );
  }

  @override
  String get name => 'check';

  @override
  String get description => 'Check whether the Figma file has a new version.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final httpClient = http.Client();
    try {
      final lock = await ProjectFiles(Directory.current.path)
          .readLock(config.lockFile);
      final meta = await TokenFetcher(
        client: CliSupport.client(config, httpClient),
        config: config,
        log: CliSupport.log,
      ).meta();
      final changed = lock?.version != meta.version;
      CliSupport.log(
        changed
            ? 'Figma version ${meta.version} differs from the lock '
                  '(${lock?.version ?? 'none'}).'
            : 'Up to date with Figma version ${meta.version}.',
      );
      await CliSupport.output('changed', '$changed');
      return changed && args.flag('exit-code') ? 1 : 0;
    } finally {
      httpClient.close();
    }
  }
}
