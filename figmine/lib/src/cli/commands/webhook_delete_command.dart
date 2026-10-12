import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';

/// `figmine webhook delete <id>`: removes a webhook.
final class WebhookDeleteCommand extends Command<int> {
  /// Creates the command.
  factory() = WebhookDeleteCommand._;

  new _() {
    argParser.addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml');
  }

  @override
  String get name => 'delete';

  @override
  String get description => 'Delete a webhook by id. Needs webhooks:write.';

  @override
  String get invocation => 'figmine webhook delete <id>';

  @override
  Future<int> run() async {
    final args = argResults!;
    if (args.rest.length != 1) usageException('Pass exactly one webhook id.');
    final id = args.rest.single;
    final config = await ConfigLoader.load(args.option('config')!);
    await CliSupport.withClient(
      config,
      (client) => client.send('DELETE', '/v2/webhooks/$id'),
    );
    CliSupport.log('Deleted webhook $id.');
    return 0;
  }
}
