import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/commands/webhook_create_command.dart';
import 'package:figmine/src/cli/commands/webhook_delete_command.dart';
import 'package:figmine/src/cli/commands/webhook_list_command.dart';

/// `figmine webhook`: manages Figma webhooks that trigger syncs.
final class WebhookCommand extends Command<int> {
  /// Creates the command with its subcommands.
  factory() = WebhookCommand._;

  new _() {
    addSubcommand(WebhookCreateCommand());
    addSubcommand(WebhookListCommand());
    addSubcommand(WebhookDeleteCommand());
  }

  @override
  String get name => 'webhook';

  @override
  String get description => 'Create, list and delete Figma webhooks.';
}
