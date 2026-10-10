import 'dart:io';

import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/pipeline/figmine_generator.dart';
import 'package:figmine/src/pipeline/generate_status.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/icons_fixture.dart';
import '../../helpers/variables_fixture.dart';

const _config = FigmineConfig(
  fileKey: 'KEY',
  tokens: TokensConfig(stripPrefix: 'color/'),
  typography: TypographyConfig(enabled: false),
  inference: InferenceConfig(mode: InferenceMode.off),
  icons: IconsConfig(nodeIds: ['1:2'], namePrefix: 'icon/'),
);

FigmineGenerator _generator(String root, String version, List<String> logs) {
  final client = fakeFigma(
    json: {
      '/v1/files/KEY/meta': metaJson(version),
      '/v1/files/KEY/variables/local': variablesJson,
      '/v1/files/KEY/nodes': iconNodesJson,
      '/v1/images/KEY': imagesJson,
    },
  );
  return FigmineGenerator(
    config: _config,
    fetcher: TokenFetcher(client: client, config: _config, log: logs.add),
    files: ProjectFiles(root),
    project: const ProjectInfo(),
    log: logs.add,
    format: false,
  );
}

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('figmine'));
  tearDown(() async => await root.delete(recursive: true));

  group(FigmineGenerator, () {
    test('writes code, icons and lock, then skips known versions', () async {
      final logs = <String>[];
      final stale = File('${root.path}/assets/figmine/icons/gone.svg');
      await stale.create(recursive: true);

      final first = await _generator(root.path, '1', logs).run();
      expect(first.status, GenerateStatus.updated);
      expect(first.report, contains('### Tokens (8)'));
      expect(
        File('${root.path}/lib/theme/tokens/color/semantic.g.dart')
            .existsSync(),
        isTrue,
      );
      expect(File('${root.path}/figmine.lock.json').existsSync(), isTrue);
      final home = File('${root.path}/assets/figmine/icons/home.svg');
      expect(await home.readAsString(), fakeSvgs['/home.svg']);
      expect(stale.existsSync(), isFalse);
      expect(logs, contains(contains('flutter.assets')));

      final second = await _generator(root.path, '1', logs).run();
      expect(second.status, GenerateStatus.upToDate);

      final third = await _generator(root.path, '2', logs).run();
      expect(third.status, GenerateStatus.unchanged);
      expect(third.report, contains('No token changes'));

      final forced = await _generator(root.path, '2', logs).run(force: true);
      expect(forced.status, GenerateStatus.updated);
      final lock = await File('${root.path}/figmine.lock.json').readAsString();
      expect(lock, contains('"version": "2"'));
    });
  });
}
