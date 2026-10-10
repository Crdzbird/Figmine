import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Keeps heavy Figma reads, the whole file and its nodes, on disk for the
/// file version they were read at, and counts the reads.
///
/// Figma limits these reads hardest, to about 20 a month for View and
/// Collab seats, so a rerun at the same version reads them from disk.
final class ReadCache {
  /// Creates a cache under [directory], usually `.figmine/cache`.
  factory(String directory) = ReadCache._;

  new _(this.directory);

  /// Folder that holds one subfolder per file and version.
  final String directory;

  static final RegExp _heavy = RegExp(r'^/v1/(files/[^/]+(/nodes)?$|images/)');

  String? _folder;

  /// Heavy reads sent to Figma.
  int fetched = 0;

  /// Heavy reads answered from disk.
  int reused = 0;

  /// Caches reads of [fileKey] at [version] from now on, dropping the
  /// reads of its older versions.
  Future<void> pin(String fileKey, String version) async {
    final file = Directory(p.join(directory, fileKey));
    if (file.existsSync()) {
      await for (final old in file.list()) {
        if (p.basename(old.path) != version) await old.delete(recursive: true);
      }
    }
    _folder = p.join(file.path, version);
    await Directory(_folder!).create(recursive: true);
    await File(p.join(directory, '.gitignore')).writeAsString('*\n');
  }

  /// Whether [path] can be kept for a file version: every read of the file
  /// except its metadata, which tells the version, and images, whose links
  /// expire.
  static bool cacheable(String path) =>
      path.startsWith('/v1/') &&
      !path.endsWith('/meta') &&
      !path.startsWith('/v1/images/');

  /// Whether [path] is a heavy read.
  bool isHeavy(String path) => _heavy.hasMatch(path);

  /// The cached body of [uri], or null.
  Future<String?> read(Uri uri) async {
    final file = _file(uri);
    if (file == null || !file.existsSync()) return null;
    if (isHeavy(uri.path)) reused++;
    return await file.readAsString();
  }

  /// Stores [body] for [uri] when it can be kept for the pinned version.
  Future<void> write(Uri uri, String body) async {
    await _file(uri)?.writeAsString(body);
  }

  File? _file(Uri uri) {
    final folder = _folder;
    if (folder == null || !cacheable(uri.path)) return null;
    final name = sha1.convert(utf8.encode(uri.toString())).toString();
    return File(p.join(folder, '$name.json'));
  }
}
