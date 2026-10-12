import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/figma/json.dart';

/// `figmine webhook list`: lists the webhooks of the configured file.
final class WebhookListCommand extends Command<int> {
  /// Creates the command.
  factory() = WebhookListCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption(
        'context',
        defaultsTo: 'file',
        allowed: ['file', 'team', 'project'],
      )
      ..addOption('context-id', help: 'Defaults to the configured file key.');
  }

  @override
  String get name => 'list';

  @override
  String get description => 'List webhooks. Needs webhooks:read.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final json = await CliSupport.withClient(
      config,
      (client) => client.getJson('/v2/webhooks', {
        'context': args.option('context')!,
        'context_id': args.option('context-id') ?? config.fileKey,
      }),
    );
    final hooks = Json.list(json['webhooks']).map(Json.map).toList();
    if (hooks.isEmpty) CliSupport.log('No webhooks.');
    for (final hook in hooks) {
      CliSupport.log(
        '${hook['id']}  ${hook['event_type']}  ${hook['status']}  '
        '${hook['endpoint']}',
      );
    }
    return 0;
  }
}
