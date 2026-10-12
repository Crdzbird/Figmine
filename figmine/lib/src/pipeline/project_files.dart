import 'dart:convert';
import 'dart:io';

import 'package:figmine/src/codegen/emit/generated_file.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/lock_json.dart';
import 'package:figmine/src/naming/token_naming.dart';
import 'package:path/path.dart' as p;

/// Reads and writes figmine files inside the project at [root].
final class ProjectFiles {
  /// Creates access to the project at [root].
  const factory(String root) = ProjectFiles._;

  const new _(this.root);

  /// Absolute path of the project.
  final String root;

  /// Reads the lock file at [path], or null when it does not exist.
  Future<LockFile?> readLock(String path) async {
    final file = File(p.join(root, path));
    if (!file.existsSync()) return null;
    return LockJson.decode(Json.map(jsonDecode(await file.readAsString())));
  }

  /// Writes [contents] to [path], creating parent folders.
  Future<void> writeText(String path, String contents) async {
    final file = File(p.join(root, path));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  /// Writes each of [files] that does not exist yet.
  ///
  /// Returns the paths that were written.
  Future<List<String>> writeMissing(List<GeneratedFile> files) async {
    final written = <String>[];
    for (final file in files) {
      if (File(p.join(root, file.path)).existsSync()) continue;
      await writeText(file.path, file.contents);
      written.add(file.path);
    }
    return written;
  }

  /// Writes every generated file.
  Future<void> writeAll(List<GeneratedFile> files) async {
    for (final file in files) {
      await writeText(file.path, file.contents);
    }
  }

  /// Writes the SVG of every icon into [directory] and deletes stale SVGs.
  Future<void> syncIcons(String directory, List<NamedIcon> icons) async {
    final folder = Directory(p.join(root, directory));
    await folder.create(recursive: true);
    final keep = {for (final icon in icons) icon.file};
    await for (final entity in folder.list()) {
      final name = p.basename(entity.path);
      if (entity is File && name.endsWith('.svg') && !keep.contains(name)) {
        await entity.delete();
      }
    }
    for (final icon in icons) {
      await writeText(p.join(directory, icon.file), icon.token.svg);
    }
  }

  /// Whether pubspec.yaml lists [directory] under `flutter.assets`.
  Future<bool> declaresAssets(String directory) async {
    final pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) return false;
    final text = await pubspec.readAsString();
    final normalized = directory.endsWith('/') ? directory : '$directory/';
    return text.contains(normalized);
  }

  /// Formats [directory] with `dart format`. Failures are reported, not thrown.
  Future<String?> format(String directory) async =>
      await formatAll([directory]);

  /// Formats the files and folders at [paths] in one `dart format` run.
  Future<String?> formatAll(List<String> paths) async {
    if (paths.isEmpty) return null;
    final result = await Process.run(Platform.resolvedExecutable, [
      'format',
      for (final path in paths) p.join(root, path),
    ]);
    if (result.exitCode == 0) return null;
    return '${result.stderr}';
  }
}
