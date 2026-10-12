import 'package:figmine/src/cli/templates/adopt_workflow_template.dart';
import 'package:figmine/src/cli/templates/tokens_workflow_template.dart';
import 'package:figmine/src/cli/templates/workflow_template.dart';

/// The GitHub workflows `figmine init` writes, with their paths.
abstract final class WorkflowFiles {
  /// The sync, adopt and tokens workflows.
  static const List<(String, String)> all = [
    ('.github/workflows/figmine_sync.yaml', WorkflowTemplate.contents),
    ('.github/workflows/figmine_adopt.yaml', AdoptWorkflowTemplate.contents),
    ('.github/workflows/figmine_tokens.yaml', TokensWorkflowTemplate.contents),
  ];
}
