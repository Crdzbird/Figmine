import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/inference/inference_result.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Tells whether the colors Figma defines are enough for a theme.
abstract final class PrimaryCoverage {
  /// Whether [collections], with the evidence of [inferred], give a
  /// primary color, or [config] sets one by hand.
  static bool given(
    List<TokenCollection> collections,
    FigmineConfig config,
    InferenceResult inferred,
  ) {
    if (config.scheme.overrides.containsKey('primary')) return true;
    final matcher = SchemeMatcher(
      collections,
      config.scheme,
      evidence: inferred.evidence,
    );
    return matcher.roles()['primary'] != null;
  }
}
