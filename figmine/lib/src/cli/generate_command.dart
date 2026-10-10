import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/pipeline/figmine_generator.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:http/http.dart' as http;

/// `figmine generate`: syncs tokens and rewrites code when Figma changed.
final class GenerateCommand extends Command<int> {
  /// Creates the command.
  factory() = GenerateCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption('report', help: 'Write a Markdown change report here.')
      ..addFlag('force', help: 'Regenerate even when nothing changed.')
      ..addFlag(
        'offline',
        negatable: false,
        help: 'Regenerate from the lock file and the cache, without Figma.',
      )
      ..addFlag(
        'migrate',
        defaultsTo: true,
        help: 'Rewrite renamed tokens in lib, test and bin.',
      )
      ..addOption(
        'layout',
        allowed: ['domain', 'figma'],
        help: 'Folder layout of the tokens, overriding output.layout.',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Fetch tokens from Figma and generate Dart code.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(
      args.option('config')!,
      layout: args.option('layout'),
    );
    final root = Directory.current.path;
    final httpClient = http.Client();
    final offline = args.flag('offline');
    final client = offline
        ? CliSupport.offlineClient(root)
        : CliSupport.client(config, httpClient);
    final cache = client.cache;
    try {
      final outcome = await FigmineGenerator(
        config: config,
        fetcher: TokenFetcher(
          client: client,
          config: config,
          log: CliSupport.log,
          root: root,
          offline: offline,
        ),
        files: ProjectFiles(root),
        project: await ProjectInfo.read(
          root,
          materialImport: config.output.materialImport,
        ),
        log: CliSupport.log,
        migrate: args.flag('migrate'),
      ).run(force: args.flag('force') || offline);
      CliSupport.log('Result: ${outcome.status.name}.');
      final reads = cache;
      if (reads != null) {
        CliSupport.log(
          'Heavy Figma reads: ${reads.fetched} sent, ${reads.reused} from '
          'the cache.',
        );
      }
      final report = args.option('report');
      if (report != null && outcome.changed) {
        await File(report).writeAsString(outcome.report);
      }
      await CliSupport.output('changed', '${outcome.changed}');
      return 0;
    } finally {
      httpClient.close();
    }
  }
}
