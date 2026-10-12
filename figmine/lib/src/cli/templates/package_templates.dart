import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

/// Copies template files that ship inside the figmine package.
abstract final class PackageTemplates {
  /// Copies [files] from `lib/<folder>` of the package into [output].
  static Future<void> copy(
    String folder,
    List<String> files,
    Directory output,
  ) async {
    await output.create(recursive: true);
    for (final name in files) {
      final source = await Isolate.resolvePackageUri(
        Uri.parse('package:figmine/$folder/$name'),
      );
      if (source == null) throw StateError('Missing template $folder/$name.');
      await File.fromUri(source).copy(p.join(output.path, name));
    }
  }
}
