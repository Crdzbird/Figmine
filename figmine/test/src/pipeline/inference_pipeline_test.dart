import 'dart:io';

import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/pipeline/figmine_generator.dart';
import 'package:figmine/src/pipeline/generate_status.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/screens_fixture.dart';
import '../../helpers/screens_tree.dart';

void main() {
  test('generates a theme from screens with only file_content:read', () async {
    final root = await Directory.systemTemp.createTemp('figmine_infer');
    addTearDown(() async => await root.delete(recursive: true));
    final logs = <String>[];
    const config = FigmineConfig(fileKey: 'KEY');
    final client = fakeFigma(
      json: {
        '/v1/files/KEY': screensTree,
        '/v1/files/KEY/nodes': screenNodesJson,
      },
      errors: {
        '/v1/files/KEY/meta': 403,
        '/v1/files/KEY/variables/local': 403,
        '/v1/files/KEY/styles': 403,
        '/v1/files/KEY/versions': 403,
      },
    );
    final outcome = await FigmineGenerator(
      config: config,
      fetcher: TokenFetcher(client: client, config: config, log: logs.add),
      files: ProjectFiles(root.path),
      project: const ProjectInfo(),
      log: logs.add,
      format: false,
    ).run();
    expect(outcome.status, GenerateStatus.updated);
    expect(logs, contains(contains('Inferred from 2 screens')));
    String read(String file) =>
        File('${root.path}/lib/theme/tokens/$file').readAsStringSync();
    expect(
      read('color/inferred/app_inferred_colors_light.g.dart'),
      contains('static const Color primary = Color(0xFF3567F6);'),
    );
    expect(
      read('units/inferred_layout/app_inferred_layout_spacing.g.dart'),
      contains('AppInferredLayoutSpacing'),
    );
    expect(
      read('color/color_scheme.g.dart'),
      contains('primary: AppInferredColorsLight.primary'),
    );
    expect(
      read('typography/text_styles.g.dart'),
      contains('bodyLarge: bodyLarge'),
    );
    expect(
      read('components/components.g.dart'),
      contains('static const double buttonRadius = 8;'),
    );
    expect(outcome.report, contains('### Components'));
    expect(
      File('${root.path}/figmine.lock.json').readAsStringSync(),
      contains('"version": "7"'),
    );
  });
}
