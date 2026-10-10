import 'package:figmine/src/figma/figma_scope.dart';

/// How a scope probe ended.
enum ProbeStatus {
  /// The endpoint answered.
  ok,

  /// The token lacks the scope, or the plan lacks the feature.
  denied,

  /// The probe needs configuration or would write, so it did not run.
  skipped,

  /// Anything else, such as a missing file.
  failed,
}

/// The outcome of probing one scope.
typedef ProbeResult = ({FigmaScope scope, ProbeStatus status, String detail});
