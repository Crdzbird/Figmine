import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/cli/generate_run.dart';
import 'package:figmine/src/cli/token_watcher.dart';
import 'package:figmine/src/config/config_loader.dart';

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
        'watch',
        negatable: false,
        help: 'Regenerate offline whenever tokens.files or the config change.',
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
    final configPath = args.option('config')!;
    final watch = args.flag('watch');
    Future<void> once() async => await GenerateRun.once(
      configPath: configPath,
      offline: watch || args.flag('offline'),
      force: args.flag('force'),
      migrate: args.flag('migrate'),
      layout: args.option('layout'),
      report: args.option('report'),
    );
    if (!watch) {
      await once();
      return 0;
    }
    final files = (await ConfigLoader.load(configPath)).tokens.files;
    if (files.isEmpty) {
      usageException('--watch follows token files. List them in tokens.files.');
    }
    await TokenWatcher.watch([...files, configPath], once, log: CliSupport.log);
    return 0;
  }
}
