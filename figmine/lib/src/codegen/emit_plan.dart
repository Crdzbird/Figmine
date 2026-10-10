import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/file_layout.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Everything decided before code is written: paths, names and the color
/// scheme fields.
typedef EmitPlan = ({
  CodegenContext context,
  TokenIndex index,
  List<SchemeField> fields,
});

/// Builds the plan shared by code generation, audits and migrations.
abstract final class EmitPlanner {
  /// Plans the generated code of [tokens].
  static EmitPlan plan(
    FigmineConfig config,
    TokenSet tokens,
    ProjectInfo project,
  ) {
    final layout = FileLayout(config.output.layout);
    final context = CodegenContext(
      prefix: config.output.classPrefix,
      project: project,
      meta: tokens.meta,
      layout: layout,
      directory: config.output.directory,
    );
    final index = TokenIndex(
      collections: tokens.collections,
      prefix: context.prefix,
      config: config.tokens,
      layout: layout,
      reservedClasses: {
        context.colorSchemeClass,
        context.typographyClass,
        context.componentsClass,
        context.componentThemesClass,
        context.iconsClass,
        context.contextExtension,
      },
    );
    final fields = SchemeFields.resolve(
      matcher: SchemeMatcher(
        tokens.collections,
        config.scheme,
        evidence: tokens.evidence,
      ),
      index: index,
      tokens: config.tokens,
    );
    return (context: context, index: index, fields: fields);
  }
}
