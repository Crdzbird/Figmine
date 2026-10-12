import 'dart:io';

import 'package:figmine/src/adopt/scheme_roles.dart';
import 'package:figmine/src/adopt/token_catalog.dart';
import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:path/path.dart' as p;

/// Loads the token catalog from the lock file and the generated scheme.
abstract final class AdoptCatalog {
  /// The catalog of the generated constants of the project at [root].
  static Future<TokenCatalog> load(String root, FigmineConfig config) async {
    final lock = await ProjectFiles(root).readLock(config.lockFile);
    if (lock == null) {
      throw ConfigException(
        'No ${config.lockFile} yet. Run figmine generate first.',
      );
    }
    final prefix = config.output.classPrefix;
    final scheme = File(
      p.join(
        root,
        config.output.directory,
        FileLayout(config.output.layout).fixed(FixedFile.colorScheme),
      ),
    );
    final roles = scheme.existsSync()
        ? SchemeRoles.read(
            await scheme.readAsString(),
            '${prefix}ColorScheme',
            lock.symbols,
          )
        : const <int, List<String>>{};
    return TokenCatalog(
      lock.symbols,
      roles: roles,
      getter: '${DartIdentifier.camel([prefix])}ColorScheme',
    );
  }
}
