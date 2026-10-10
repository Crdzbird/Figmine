import 'package:figmine/src/doctor/probe_result.dart';
import 'package:figmine/src/figma/figma_scope.dart';

/// Renders probe results and the strategy figmine will use.
abstract final class DoctorReport {
  /// Returns a plain text report of [results].
  static String render(List<ProbeResult> results) {
    final width = results.fold(
      0,
      (w, r) => r.scope.id.length > w ? r.scope.id.length : w,
    );
    final buffer = StringBuffer();
    for (final r in results) {
      final mark = switch (r.status) {
        ProbeStatus.ok => 'ok     ',
        ProbeStatus.denied => 'denied ',
        ProbeStatus.skipped => 'skipped',
        ProbeStatus.failed => 'failed ',
      };
      final detail = r.detail.isEmpty ? '' : ' (${r.detail})';
      buffer.writeln(
        '$mark  ${r.scope.id.padRight(width)}  ${r.scope.enables}$detail',
      );
    }
    buffer
      ..writeln()
      ..writeln(strategy(results));
    return buffer.toString();
  }

  /// Describes where tokens will come from given [results].
  static String strategy(List<ProbeResult> results) {
    bool ok(FigmaScope scope) =>
        results.any((r) => r.scope == scope && r.status == ProbeStatus.ok);
    if (results.any((r) => r.detail == 'HTTP 401')) {
      return 'Figma rejected the token (HTTP 401). Check that FIGMA_TOKEN '
          'holds a valid, unexpired personal access token.';
    }
    final notFound = results.any(
      (r) => r.scope == FigmaScope.fileContentRead && r.detail == 'HTTP 404',
    );
    if (notFound) {
      return 'The token works, but Figma found no file with this key that '
          'its owner can open. Copy the file URL into figma.file_key, and '
          'check the owner has at least view access to the file.';
    }
    if (!ok(FigmaScope.fileContentRead)) {
      return 'file_content:read is required. Grant it, or check the file key '
          'and that the token owner can open the file.';
    }
    if (ok(FigmaScope.fileVariablesRead)) {
      return 'Tokens come from Variables. Screens add spacing, radius and '
          'component metrics.';
    }
    return 'Variables are unavailable: tokens come from color and text styles, '
        'and when the file has none, they are inferred from the screens. To '
        'read the real variables, dark mode included, run figmine exporter '
        'and list the exported JSON in tokens.files.';
  }

  /// Whether figmine can work with [results].
  static bool usable(List<ProbeResult> results) => results.any(
    (r) => r.scope == FigmaScope.fileContentRead && r.status == ProbeStatus.ok,
  );
}
