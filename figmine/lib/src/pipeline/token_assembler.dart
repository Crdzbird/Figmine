import 'package:figmine/src/config/component_pins.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/pipeline/primary_coverage.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/sources/styles/style_typography.dart';
import 'package:figmine/src/tokens/icon_token.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Combines defined tokens with tokens inferred from the screens.
final class TokenAssembler {
  /// Creates an assembler for [config].
  const factory({
    required FigmineConfig config,
    required void Function(String message) log,
  }) = TokenAssembler._;

  const new _({required this.config, required this.log});

  /// The project configuration.
  final FigmineConfig config;

  /// Receives progress messages.
  final void Function(String message) log;

  static const String _noDark =
      'No dark screens, so dark mode is derived. To use the dark mode of '
      'the design, run figmine exporter and list the JSON in tokens.files.';

  /// Builds the token set.
  ///
  /// In `auto` mode inferred colors are only used when the colors Figma
  /// defines give no primary, such as a lone image placeholder style, and
  /// inferred text styles only when Figma defines none. Layout scales and
  /// component metrics are always used. In `always` mode everything
  /// inferred is added.
  TokenSet assemble({
    required FigmaFileMeta meta,
    required List<TokenCollection> collections,
    required List<StyleNode> styles,
    required ScreenSet? screens,
    required List<IconToken> icons,
    List<TextStyleToken> fileTextStyles = const [],
  }) {
    final fromFiles = {for (final s in fileTextStyles) s.name.toLowerCase()};
    final defined = [
      ...fileTextStyles,
      for (final style in StyleTypography.collect(styles, config.typography))
        if (!fromFiles.contains(style.name.toLowerCase())) style,
    ];
    final count = collections.fold(0, (sum, c) => sum + c.tokens.length);
    log('Read $count tokens and ${defined.length} text styles from Figma.');
    if (screens == null) {
      return TokenSet(
        meta: meta,
        collections: collections,
        textStyles: defined,
        icons: icons,
        components: ComponentPins.apply(const {}, config.components),
      );
    }
    final always = config.inference.mode == InferenceMode.always;
    final inferred = DesignInference.analyze(screens, config.tokens);
    final useColors =
        always || !PrimaryCoverage.given(collections, config, inferred);
    final useText = config.typography.enabled && (always || defined.isEmpty);
    log(
      'Inferred from ${inferred.frames} screens: '
      '${useColors ? inferred.colors?.tokens.length ?? 0 : 0} colors, '
      '${inferred.layout?.tokens.length ?? 0} layout values, '
      '${useText ? inferred.textStyles.length : 0} text styles.',
    );
    if (useColors && inferred.darkScreens == 0) log(_noDark);
    return TokenSet(
      meta: meta,
      collections: [
        ...collections,
        if (useColors) ?inferred.colors,
        ?inferred.layout,
      ],
      textStyles: [...defined, if (useText) ...inferred.textStyles],
      icons: icons,
      components: ComponentPins.apply(inferred.components, config.components),
      evidence: inferred.evidence,
    );
  }
}
