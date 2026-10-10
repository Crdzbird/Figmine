import 'dart:io';

import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:figmine/src/score/offline_client.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Process level helpers shared by the commands.
abstract final class CliSupport {
  /// Creates a Figma client with the token from the configured variable.
  static FigmaClient client(FigmineConfig config, http.Client httpClient) {
    final token = Platform.environment[config.tokenEnv] ?? '';
    if (token.isEmpty) {
      throw ConfigException(
        'Set the ${config.tokenEnv} environment variable to a Figma personal '
        'access token with at least file_content:read. Run figmine doctor '
        'to see what the other scopes add.',
      );
    }
    return FigmaClient(
      httpClient: httpClient,
      token: token,
      cache: ReadCache(p.join('.figmine', 'cache')),
    );
  }

  /// A client that reads only the cache of the project at [root].
  static FigmaClient offlineClient(String root) => FigmaClient(
    httpClient: OfflineClient(),
    token: 'offline',
    cache: ReadCache(p.join(root, '.figmine', 'cache')),
  );

  /// Runs [body] with a Figma client for [config], closing it afterwards.
  static Future<T> withClient<T>(
    FigmineConfig config,
    Future<T> Function(FigmaClient client) body,
  ) async {
    final httpClient = http.Client();
    try {
      return await body(client(config, httpClient));
    } finally {
      httpClient.close();
    }
  }

  /// Writes `key=value` to the GitHub Actions step output, when available.
  static Future<void> output(String key, String value) async {
    final path = Platform.environment['GITHUB_OUTPUT'];
    if (path == null || path.isEmpty) return;
    await File(path).writeAsString('$key=$value\n', mode: FileMode.append);
  }

  /// Prints a progress line.
  static void log(String message) => stdout.writeln(message);
}
