import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/score/offline_client.dart';
import 'package:figmine/src/score/theme_snapshot.dart';
import 'package:figmine/src/screens/screen_loader.dart';
import 'package:figmine/src/sources/collection_modes.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
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
    final colors = result.colors;
    final modes = colors == null
        ? null
        : CollectionModes.pick(colors.modes, config.tokens);
    return (
      light: _colors(colors, modes?.light),
      dark: _colors(colors, modes?.dark),
      components: {
        for (final e in result.components.entries) e.key: e.value.value,
      },
      text: {
        for (final s in result.textStyles)
          s.name: (family: s.fontFamily, size: s.fontSize),
      },
    );
  }

  static Map<String, int> _colors(TokenCollection? colors, String? mode) => {
    for (final t in colors?.tokens ?? const <DesignToken>[])
      if (t.values[mode]?.value case final ColorValue c) t.name: c.argb,
  };
}
