import 'package:figmine/src/doctor/probe_result.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_rate_limit.dart';
import 'package:figmine/src/figma/figma_scope.dart';

/// Turns failed probes into doctor results.
abstract final class ProbeFailure {
  /// A probe Figma answered with an error: denied for 401 and 403.
  static ProbeResult of(FigmaScope scope, FigmaException error) {
    final denied = error.statusCode == 403 || error.statusCode == 401;
    return (
      scope: scope,
      status: denied ? ProbeStatus.denied : ProbeStatus.failed,
      detail: 'HTTP ${error.statusCode}',
    );
  }

  /// A probe Figma rate limited, with the wait and the kind of seat.
  static ProbeResult limited(FigmaScope scope, FigmaRateLimit limit) {
    final seat = limit.type == 'low' ? ', View or Collab seat' : '';
    return (
      scope: scope,
      status: ProbeStatus.failed,
      detail: 'rate limited for ${limit.wait}$seat',
    );
  }
}
