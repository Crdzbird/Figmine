import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';

/// `figmine comment`: posts a comment on the Figma file, such as the link
/// to the pull request that synced it.
final class CommentCommand extends Command<int> {
  /// Creates the command.
  factory() = CommentCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption('pr-url', help: 'Pull request to link in the comment.')
      ..addOption('message', help: 'Custom comment text.');
  }

  @override
  String get name => 'comment';

  @override
  String get description =>
      'Comment on the Figma file. Needs file_comments:write.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final pr = args.option('pr-url');
    final message =
        args.option('message') ??
        (pr == null
            ? null
            : 'figmine synced these design changes into code. '
                  'Review the pull request: $pr');
    if (message == null) usageException('Pass --pr-url or --message.');
    final config = await ConfigLoader.load(args.option('config')!);
    await CliSupport.withClient(
      config,
      (client) => client.send(
        'POST',
        '/v1/files/${config.fileKey}/comments',
        body: {
          'message': message,
          'client_meta': {'x': 0, 'y': 0},
        },
      ),
    );
    CliSupport.log('Commented on the Figma file.');
    return 0;
  }
}
