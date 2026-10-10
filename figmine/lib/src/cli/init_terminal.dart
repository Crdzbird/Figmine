import 'dart:io';

import 'package:figmine/src/cli/file_offer.dart';
import 'package:figmine/src/cli/init_prompt.dart';
import 'package:figmine/src/cli/init_wizard.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:http/http.dart' as http;

/// Runs the `figmine init` questions on the terminal.
abstract final class InitTerminal {
  /// The answers, probing the file when `FIGMA_TOKEN` is set.
  static Future<InitAnswers> ask() async {
    final token = Platform.environment['FIGMA_TOKEN'] ?? '';
    final client = http.Client();
    try {
      return await InitWizard.ask(
        InitPrompt(read: stdin.readLineSync, write: stdout.write),
        token.isEmpty
            ? null
            : (key) async => await FileOffers.probe(
                FigmaClient(httpClient: client, token: token),
                key,
              ),
      );
    } finally {
      client.close();
    }
  }
}
