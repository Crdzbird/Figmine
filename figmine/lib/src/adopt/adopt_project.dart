import 'dart:io';

import 'package:figmine/src/adopt/adopt_catalog.dart';
import 'package:figmine/src/adopt/adopt_rewriter.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/literal_scanner.dart';
import 'package:figmine/src/adopt/suggestion.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:path/path.dart' as p;

/// Hard coded values found in one file, with their tokens.
typedef AdoptFile = ({String path, String source, List<Suggestion> found});

/// Finds hard coded design values in a project, using only the lock file
/// and the generated code, without calling Figma.
final class AdoptProject {
  /// Creates the scan of the project at [root] configured by [config].
  const factory(String root, FigmineConfig config) = AdoptProject._;

  const new _(this.root, this.config);

  /// The project folder.
  final String root;

  /// The project configuration.
  final FigmineConfig config;

  /// Every Dart file under [paths], except generated code, with the hard
  /// coded values that match a token, and every hard coded color.
  Future<List<AdoptFile>> scan(List<String> paths) async {
    final tokens = await AdoptCatalog.load(root, config);
    final generated = p.normalize(p.join(root, config.output.directory));
    final files = <AdoptFile>[];
    for (final path in paths) {
      final dir = Directory(p.join(root, path));
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list(recursive: true)) {
        final file = entity.path;
        if (entity is! File || !file.endsWith('.dart')) continue;
        if (file.endsWith('.g.dart') || p.isWithin(generated, file)) continue;
        final source = await entity.readAsString();
        final relative = p.relative(file, from: root);
        final found = [
          for (final literal in LiteralScanner.scan(source, relative))
            if (tokens.suggest(literal) case final s
                when literal.kind == LiteralKind.color ||
                    s.constant != null ||
                    s.others.isNotEmpty)
              s,
        ];
        if (found.isNotEmpty) {
          files.add((path: relative, source: source, found: found));
        }
      }
    }
    return files..sort((a, b) => a.path.compareTo(b.path));
  }

  /// Replaces the values of [files] that have one best token, adds the
  /// tokens import of [package], formats them, and returns their paths.
  Future<List<String>> apply(List<AdoptFile> files, String package) async {
    final updated = <String>[];
    for (final file in files) {
      final source = AdoptRewriter.apply(
        file.source,
        file.found,
        barrel(package),
      );
      if (source == file.source) continue;
      await File(p.join(root, file.path)).writeAsString(source);
      await ProjectFiles(root).format(file.path);
      updated.add(file.path);
    }
    return updated;
  }

  /// The import of the generated barrel, such as
  /// `package:app/theme/tokens/figmine.g.dart`.
  String barrel(String package) {
    final dir = p.posix.relative(config.output.directory, from: 'lib');
    return 'package:$package/$dir/figmine.g.dart';
  }
}
