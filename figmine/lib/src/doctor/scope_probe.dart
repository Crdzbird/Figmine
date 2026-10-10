import 'package:figmine/src/doctor/probe_failure.dart';
import 'package:figmine/src/doctor/probe_result.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_rate_limit.dart';
import 'package:figmine/src/figma/figma_scope.dart';
import 'package:figmine/src/figma/json.dart';

/// Checks which scopes a token can use on a file with read only requests.
final class ScopeProbe {
  /// Creates a probe for [fileKey], and [teamId] when configured.
  const factory({
    required FigmaClient client,
    required String fileKey,
    String? teamId,
  }) = ScopeProbe._;

  const new _({required this.client, required this.fileKey, this.teamId});

  /// The Figma client.
  final FigmaClient client;

  /// The file to probe.
  final String fileKey;

  /// The team to probe, when configured.
  final String? teamId;

  /// Probes every scope. Write scopes are reported as skipped.
  Future<List<ProbeResult>> run() async {
    final file = '/v1/files/$fileKey';
    String? styleKey;
    final styles = await _probe(
      FigmaScope.libraryContentRead,
      '$file/styles',
      read: (json) {
        final list = Json.list(Json.map(json['meta'])['styles']);
        styleKey = list.isEmpty ? null : '${Json.map(list.first)['key']}';
        return '${list.length} published styles';
      },
    );
    return [
      await _probe(FigmaScope.currentUserRead, '/v1/me', field: 'handle'),
      await _probe(FigmaScope.fileContentRead, file, query: {'depth': '1'}),
      await _probe(FigmaScope.fileMetadataRead, '$file/meta'),
      await _probe(FigmaScope.fileVersionsRead, '$file/versions'),
      await _probe(FigmaScope.fileVariablesRead, '$file/variables/local'),
      styles,
      await _assets(styleKey),
      await _team(teamId),
      await _probe(
        FigmaScope.webhooksRead,
        '/v2/webhooks',
        query: {'context': 'file', 'context_id': fileKey},
      ),
      _skip(FigmaScope.webhooksWrite, 'write scope, not probed'),
      _skip(FigmaScope.fileCommentsWrite, 'write scope, not probed'),
    ];
  }

  Future<ProbeResult> _probe(
    FigmaScope scope,
    String path, {
    Map<String, String> query = const {},
    String field = 'name',
    String Function(Map<String, Object?> json)? read,
  }) async {
    try {
      final json = await client.getJson(path, query);
      final detail = read?.call(json) ?? '${json[field] ?? ''}';
      return (scope: scope, status: ProbeStatus.ok, detail: detail);
    } on FigmaException catch (error) {
      return ProbeFailure.of(scope, error);
    } on FigmaRateLimit catch (limit) {
      return ProbeFailure.limited(scope, limit);
    }
  }

  Future<ProbeResult> _assets(String? key) async {
    if (key == null) {
      return _skip(FigmaScope.libraryAssetsRead, 'needs a published style');
    }
    return await _probe(FigmaScope.libraryAssetsRead, '/v1/styles/$key');
  }

  Future<ProbeResult> _team(String? team) async {
    if (team == null) {
      return _skip(FigmaScope.teamLibraryContentRead, 'set library.team_id');
    }
    return await _probe(
      FigmaScope.teamLibraryContentRead,
      '/v1/teams/$team/styles',
      query: {'page_size': '1'},
    );
  }

  ProbeResult _skip(FigmaScope scope, String why) =>
      (scope: scope, status: ProbeStatus.skipped, detail: why);
}
