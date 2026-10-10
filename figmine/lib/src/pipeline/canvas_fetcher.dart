import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/pipeline/offline_source.dart';
import 'package:figmine/src/screens/screen_loader.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/sources/icons_source.dart';
import 'package:figmine/src/tokens/icon_token.dart';

/// Reads what lives on the canvas: the screens and the icon components.
final class CanvasFetcher {
  /// Creates a fetcher for the file in [config].
  const factory({
    required FigmaClient client,
    required FigmineConfig config,
    required void Function(String message) log,
  }) = CanvasFetcher._;

  const new _({required this.client, required this.config, required this.log});

  /// The Figma client.
  final FigmaClient client;

  /// The project configuration.
  final FigmineConfig config;

  /// Receives progress messages.
  final void Function(String message) log;

  /// The screens to analyze, or null when inference is off. [offline],
  /// screens never cached for this version are skipped, not an error.
  Future<ScreenSet?> screens({bool offline = false}) async {
    if (config.inference.mode == InferenceMode.off) return null;
    final ScreenSet screens;
    try {
      screens = await ScreenLoader(
        client: client,
        config: config.inference,
      ).load(config.fileKey);
    } on FigmaException catch (error) {
      if (!offline || error.statusCode != 404) rethrow;
      log('No screens cached for this version, so nothing is inferred.');
      return null;
    }
    log('Loaded ${screens.frames.length} screens for inference.');
    return screens;
  }

  /// The exported icons, or none without an icons section. [offline], the
  /// icons exported before, read from the project at [root].
  Future<List<IconToken>> icons({
    bool offline = false,
    String root = '.',
  }) async {
    if (offline) return await OfflineSource.icons(root, config);
    final iconsConfig = config.icons;
    if (iconsConfig == null) return const [];
    final icons = await IconsSource(
      client: client,
      config: iconsConfig,
    ).fetch(config.fileKey);
    log('Exported ${icons.length} icons.');
    return icons;
  }
}
