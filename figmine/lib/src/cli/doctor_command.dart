import 'package:args/command_runner.dart';
import 'package:figmine/src/cli/cli_support.dart';
import 'package:figmine/src/config/config_loader.dart';
import 'package:figmine/src/doctor/doctor_report.dart';
import 'package:figmine/src/doctor/scope_probe.dart';
import 'package:http/http.dart' as http;

/// `figmine doctor`: checks the token scopes against the configured file.
final class DoctorCommand extends Command<int> {
  /// Creates the command.
  factory() = DoctorCommand._;

  new _() {
    argParser.addOption('config', abbr: 'c', defaultsTo: 'figmine.yaml');
  }

  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Check which Figma scopes the token has and how tokens will be read.';

  @override
  Future<int> run() async {
    final config = await ConfigLoader.load(argResults!.option('config')!);
    final httpClient = http.Client();
    try {
      final results = await ScopeProbe(
        client: CliSupport.client(config, httpClient),
        fileKey: config.fileKey,
        teamId: config.library.teamId,
      ).run();
      CliSupport.log(DoctorReport.render(results));
      return DoctorReport.usable(results) ? 0 : 1;
    } finally {
      httpClient.close();
    }
  }
}
