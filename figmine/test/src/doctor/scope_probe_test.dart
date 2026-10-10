import 'package:figmine/src/doctor/doctor_report.dart';
import 'package:figmine/src/doctor/probe_result.dart';
import 'package:figmine/src/doctor/scope_probe.dart';
import 'package:figmine/src/figma/figma_scope.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';

void main() {
  test('reports granted, denied and skipped scopes', () async {
    final results = await ScopeProbe(
      client: fakeFigma(
        json: {
          '/v1/me': {'handle': 'luis'},
          '/v1/files/KEY': {'name': 'App'},
          '/v1/files/KEY/versions': {'versions': <Object?>[]},
          '/v1/files/KEY/styles': {
            'meta': {
              'styles': [
                {'key': 'abc'},
              ],
            },
          },
          '/v1/styles/abc': {'meta': <String, Object?>{}},
          '/v2/webhooks': {'webhooks': <Object?>[]},
        },
        errors: {
          '/v1/files/KEY/meta': 403,
          '/v1/files/KEY/variables/local': 403,
        },
      ),
      fileKey: 'KEY',
    ).run();
    final status = {for (final r in results) r.scope: r.status};
    expect(status[FigmaScope.currentUserRead], ProbeStatus.ok);
    expect(status[FigmaScope.fileContentRead], ProbeStatus.ok);
    expect(status[FigmaScope.fileMetadataRead], ProbeStatus.denied);
    expect(status[FigmaScope.fileVariablesRead], ProbeStatus.denied);
    expect(status[FigmaScope.libraryAssetsRead], ProbeStatus.ok);
    expect(status[FigmaScope.teamLibraryContentRead], ProbeStatus.skipped);
    expect(status[FigmaScope.webhooksWrite], ProbeStatus.skipped);
    expect(results, hasLength(FigmaScope.values.length));
    final report = DoctorReport.render(results);
    expect(report, contains('ok       current_user:read'));
    expect(report, contains('inferred from the screens'));
    expect(DoctorReport.usable(results), isTrue);
  });
}
