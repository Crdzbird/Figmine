import 'dart:io';

import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/score/scheme_values.dart';
import 'package:figmine/src/score/text_values.dart';
import 'package:figmine/src/score/theme_snapshot.dart';
import 'package:path/path.dart' as p;

/// Reads the theme figmine generated, from the lock file and the code.
abstract final class GeneratedSnapshot {
  /// The generated theme of the project at [root].
  static Future<ThemeSnapshot> read(String root, FigmineConfig config) async {
    final lock = await ProjectFiles(root).readLock(config.lockFile);
    if (lock == null) {
      throw ConfigException(
        'No ${config.lockFile} yet. Run figmine generate first.',
      );
    }
    final layout = FileLayout(config.output.layout);
    Future<String> source(FixedFile file) async {
      final f = File(p.join(root, config.output.directory, layout.fixed(file)));
      return f.existsSync() ? await f.readAsString() : '';
    }

    final scheme = await source(FixedFile.colorScheme);
    final name = '${config.output.classPrefix}ColorScheme';
    return (
      light: SchemeValues.read(scheme, name, lock.symbols, 'light'),
      dark: SchemeValues.read(scheme, name, lock.symbols, 'dark'),
      components: {
        for (final e in lock.components.entries)
          e.key: ?double.tryParse(e.value),
      },
      text: TextValues.read(await source(FixedFile.textStyles)),
    );
  }
}
