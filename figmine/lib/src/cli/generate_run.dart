import 'dart:io';

import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/pipeline/figmine_generator.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:http/http.dart' as http;

/// One sync of `figmine generate` in the current folder.
abstract final class GenerateRun {
  /// Loads [configPath] and syncs. [offline] reads the lock file and the
  /// cache instead of Figma. A [report] is written when files changed.
  static Future<void> once({
    required String configPath,
    required bool offline,
    required bool force,
    required bool migrate,
    String? layout,
    String? report,
  }) async {
    final config = await ConfigLoader.load(configPath, layout: layout);
    final root = Directory.current.path;
    final httpClient = http.Client();
    final client = offline
        ? CliSupport.offlineClient(root)
        : CliSupport.client(config, httpClient);
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
        migrate: migrate,
      ).run(force: force || offline);
      CliSupport.log('Result: ${outcome.status.name}.');
      final reads = client.cache;
      if (reads != null) {
        CliSupport.log(
          'Heavy Figma reads: ${reads.fetched} sent, ${reads.reused} from '
          'the cache.',
        );
      }
      if (report != null && outcome.changed) {
        await File(report).writeAsString(outcome.report);
      }
      await CliSupport.output('changed', '${outcome.changed}');
    } finally {
      httpClient.close();
    }
  }
}
