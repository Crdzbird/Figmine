import 'package:figmine/src/audit/audit_result.dart';
import 'package:figmine/src/audit/contrast_audit.dart';
import 'package:figmine/src/audit/contrast_fixer.dart';
import 'package:figmine/src/audit/fix_candidates.dart';
import 'package:figmine/src/audit/fix_snippet.dart';
import 'package:figmine/src/codegen/emit_plan.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/migrate/code_migrator.dart';
import 'package:figmine/src/migrate/migrations.dart';
import 'package:figmine/src/migrate/symbol_table.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// What a sync found before writing anything.
typedef SyncAnalysis = ({
  LockFile lock,
  AuditResult audit,
  MigrationPlan migration,
});

/// Audits the new tokens and plans the code migration.
abstract final class SyncAnalyzer {
  /// Analyzes [tokens] against the [previous] lock. Without a [migrator]
  /// the code is not scanned.
  static Future<SyncAnalysis> analyze({
    required FigmineConfig config,
    required TokenSet tokens,
    required ProjectInfo project,
    required LockFile? previous,
    CodeMigrator? migrator,
  }) async {
    final plan = EmitPlanner.plan(config, tokens, project);
    final symbols = SymbolTable.of(plan.index);
    final migration = migrator == null
        ? Migrations.none
        : await Migrations.plan(
            previous: previous,
            next: symbols,
            migrator: migrator,
          );
    return (
      lock: LockFile.of(
        config.fileKey,
        tokens,
        symbols: symbols,
      ).withDeprecated(migration.deprecated),
      audit: _audit(plan.fields, tokens, config),
      migration: migration,
    );
  }

  static AuditResult _audit(
    List<SchemeField> fields,
    TokenSet tokens,
    FigmineConfig config,
  ) {
    final findings = ContrastAudit.run(fields);
    final fixes = ContrastFixer.suggest(
      findings,
      fields,
      FixCandidates.of(tokens.collections, config.tokens),
    );
    return (
      findings: findings,
      checked: ContrastAudit.pairs(fields).length * 2,
      fixes: fixes,
      snippet: FixSnippet.yaml(findings, fixes, fields),
    );
  }
}
