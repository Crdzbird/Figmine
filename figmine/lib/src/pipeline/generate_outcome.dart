import 'package:figmine/src/pipeline/generate_status.dart';

/// The result of a generate run.
final class GenerateOutcome {
  /// Creates an outcome.
  const factory({required GenerateStatus status, String report}) =
      GenerateOutcome._;

  const new _({required this.status, this.report = ''});

  /// What the run did.
  final GenerateStatus status;

  /// Markdown change report, empty when nothing was fetched.
  final String report;

  /// Whether files were written.
  bool get changed => status == GenerateStatus.updated;
}
