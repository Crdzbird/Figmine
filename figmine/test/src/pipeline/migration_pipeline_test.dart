import 'dart:convert';
import 'dart:io';

import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/pipeline/figmine_generator.dart';
import 'package:figmine/src/pipeline/generate_outcome.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/variables_fixture.dart';

const _config = FigmineConfig(
  fileKey: 'KEY',
  tokens: TokensConfig(stripPrefix: 'color/'),
  typography: TypographyConfig(enabled: false),
  inference: InferenceConfig(mode: InferenceMode.off),
);

Future<GenerateOutcome> _sync(
  String root,
  String version,
  Map<String, Object?> vars,
) => FigmineGenerator(
  config: _config,
  fetcher: TokenFetcher(
    client: fakeFigma(
      json: {
        '/v1/files/KEY/meta': metaJson(version),
        '/v1/files/KEY/variables/local': vars,
      },
    ),
    config: _config,
    log: (_) {},
  ),
  files: ProjectFiles(root),
  project: const ProjectInfo(packageName: 'app'),
  log: (_) {},
  format: false,
).run();

void main() {
  test('renames in Figma rewrite code, removals become deprecated', () async {
    final root = (await Directory.systemTemp.createTemp('figmine_sync')).path;
    addTearDown(() async => await Directory(root).delete(recursive: true));
    await _sync(root, '1', variablesJson);
    final app = File('$root/lib/app.dart');
    await app.writeAsString(
      'final a = AppPrimitivesPaletteBlue.v500;\n'
      'final r = AppPrimitivesRadius.v16;\n',
    );

    final edited =
        jsonDecode(jsonEncode(variablesJson)) as Map<String, Object?>;
    final vars = (edited['meta']! as Map)['variables']! as Map;
    (vars['V:blue']! as Map)['name'] = 'palette/brand/500';
    vars.remove('V:radius');
    final outcome = await _sync(root, '2', edited);

    expect(
      await app.readAsString(),
      contains('AppPrimitivesPaletteBrand.v500'),
    );
    final deprecated = await File(
      '$root/lib/theme/tokens/deprecated/app_primitives_radius.g.dart',
    ).readAsString();
    expect(deprecated, contains('abstract final class AppPrimitivesRadius {'));
    expect(deprecated, contains('@Deprecated('));
    expect(deprecated, contains('static const double v16 = 16;'));
    expect(outcome.report, contains('### Code impact'));
    expect(
      outcome.report,
      contains(
        '`AppPrimitivesPaletteBlue.v500` to '
        '`AppPrimitivesPaletteBrand.v500` (1 files)',
      ),
    );
    expect(
      outcome.report,
      contains('`AppPrimitivesRadius.v16` in `lib/app.dart`'),
    );

    await app.writeAsString('final a = AppPrimitivesPaletteBrand.v500;\n');
    await _sync(root, '3', edited);
    expect(
      Directory('$root/lib/theme/tokens/deprecated').existsSync(),
      isFalse,
    );
  });
}
