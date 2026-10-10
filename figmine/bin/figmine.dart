import 'dart:io';

import 'package:figmine/src/cli/figmine_command_runner.dart';

Future<void> main(List<String> args) async {
  exitCode = await FigmineCommandRunner().run(args);
}
