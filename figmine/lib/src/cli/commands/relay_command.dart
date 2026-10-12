import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/cli/templates/package_templates.dart';

/// `figmine relay`: writes a Cloudflare Worker that turns Figma webhooks
/// into GitHub repository dispatches for instant syncs.
final class RelayCommand extends Command<int> {
  /// Creates the command.
  factory() = RelayCommand._;

  new _() {
    argParser.addOption('output', abbr: 'o', defaultsTo: 'figma_relay');
  }

  @override
  String get name => 'relay';

  @override
  String get description => 'Write the webhook relay for Cloudflare Workers.';

  @override
  Future<int> run() async {
    final output = Directory(argResults!.option('output')!);
    await PackageTemplates.copy('relay', [
      'worker.mjs',
      'wrangler.toml',
    ], output);
    final dir = output.path;
    CliSupport.log('''
Wrote the relay to $dir. To deploy it:
  1. Set GITHUB_REPOSITORY in $dir/wrangler.toml, and FIGMA_FILE_KEY to
     ignore other files.
  2. cd $dir && npx wrangler secret put GITHUB_TOKEN
     A fine grained token with Contents read and write on the repository.
  3. npx wrangler secret put FIGMA_WEBHOOK_PASSCODE
  4. npx wrangler deploy
  5. FIGMA_WEBHOOK_PASSCODE=<same value> dart run figmine webhook create \\
       --endpoint <the workers.dev URL>''');
    return 0;
  }
}
