import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/scheme/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/inference/inference_result.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/score/offline_client.dart';
import 'package:figmine/src/score/theme_snapshot.dart';
import 'package:figmine/src/screens/screen_loader.dart';
import 'package:path/path.dart' as p;

/// Infers a theme from the cached screens alone, ignoring every token.
abstract final class InferredSnapshot {
  /// The theme inferred from the screens of the project at [root], read
  /// from the cache of the version in its lock file, without the network.
  static Future<ThemeSnapshot> read(String root, FigmineConfig config) async {
    final lock = await ProjectFiles(root).readLock(config.lockFile);
    if (lock == null) {
      throw ConfigException(
        'No ${config.lockFile} yet. Run figmine generate first.',
      );
    }
    final cache = ReadCache(p.join(root, '.figmine', 'cache'));
    await cache.pin(config.fileKey, lock.version);
    final client = FigmaClient(
      httpClient: OfflineClient(),
      token: 'offline',
      cache: cache,
    );
    final screens = await ScreenLoader(
      client: client,
      config: config.inference,
    ).load(config.fileKey);
    final result = DesignInference.analyze(screens, config.tokens);
    final fields = scheme(result, config.tokens);
    return (
      light: {for (final f in fields) f.name: f.lightArgb},
      dark: {for (final f in fields) f.name: f.darkArgb},
      components: {
        for (final e in result.components.entries) e.key: e.value.value,
      },
      text: {
        for (final s in result.textStyles)
          s.name: (family: s.fontFamily, size: s.fontSize),
      },
    );
  }

  /// The color scheme `generate` would build from [result] alone, with
  /// derived roles such as containers, and no hand set roles.
  static List<SchemeField> scheme(InferenceResult result, TokensConfig c) {
    final collections = [?result.colors, ?result.layout];
    final index = TokenIndex(
      collections: collections,
      prefix: 'App',
      config: c,
    );
    return SchemeFields.resolve(
      matcher: SchemeMatcher(
        collections,
        const SchemeConfig(),
        evidence: result.evidence,
      ),
      index: index,
      tokens: c,
    );
  }
}
