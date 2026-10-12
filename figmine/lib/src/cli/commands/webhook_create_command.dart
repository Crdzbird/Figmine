import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/config_loader.dart';

/// `figmine webhook create`: registers a Figma webhook for instant syncs.
final class WebhookCreateCommand extends Command<int> {
  /// Creates the command.
  factory() = WebhookCreateCommand._;

  new _() {
    argParser
      ..addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml')
      ..addOption('endpoint', help: 'HTTPS URL of your relay.', mandatory: true)
      ..addOption(
        'event',
        defaultsTo: 'FILE_UPDATE',
        allowed: ['FILE_UPDATE', 'FILE_VERSION_UPDATE', 'LIBRARY_PUBLISH'],
      )
      ..addOption(
        'context',
        defaultsTo: 'file',
        allowed: ['file', 'team', 'project'],
      )
      ..addOption('context-id', help: 'Defaults to the configured file key.')
      ..addOption(
        'passcode-env',
        defaultsTo: 'FIGMA_WEBHOOK_PASSCODE',
        help: 'Environment variable holding the passcode Figma sends back.',
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Register a Figma webhook. Needs webhooks:write.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final config = await ConfigLoader.load(args.option('config')!);
    final passcodeEnv = args.option('passcode-env')!;
    final passcode = Platform.environment[passcodeEnv] ?? '';
    if (passcode.isEmpty) {
      throw ConfigException('Set $passcodeEnv to the webhook passcode.');
    }
    final webhook = await CliSupport.withClient(
      config,
      (client) => client.send(
        'POST',
        '/v2/webhooks',
        body: {
          'event_type': args.option('event'),
          'context': args.option('context'),
          'context_id': args.option('context-id') ?? config.fileKey,
          'endpoint': args.option('endpoint'),
          'passcode': passcode,
          'description': 'figmine sync',
        },
      ),
    );
    CliSupport.log(
      'Created webhook ${webhook['id']} (${webhook['status'] ?? 'ACTIVE'}). '
      'Figma sends a PING to the endpoint now.',
    );
    return 0;
  }
}
