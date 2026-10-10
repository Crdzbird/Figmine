import 'dart:convert';

import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/lock_symbol.dart';

/// Encodes and decodes the lock file.
abstract final class LockJson {
  /// Reads a lock file written by [encode]. Older lock files without some
  /// sections, or with `colors` instead of `tokens`, are accepted.
  static LockFile decode(Map<String, Object?> json) => LockFile(
    fileKey: '${json['fileKey'] ?? ''}',
    version: '${json['version'] ?? ''}',
    lastModified: '${json['lastModified'] ?? ''}',
    fileName: '${json['fileName'] ?? ''}',
    tokens: _strings(json['tokens'] ?? json['colors']),
    typography: _strings(json['typography']),
    components: _strings(json['components']),
    icons: _strings(json['icons']),
    symbols: LockSymbols.fromJson(json['symbols']),
    deprecated: LockSymbols.fromJson(json['deprecated']),
  );

  /// Encodes [lock] as stable, pretty printed JSON.
  static String encode(LockFile lock) {
    final json = {
      'fileKey': lock.fileKey,
      'version': lock.version,
      'lastModified': lock.lastModified,
      'fileName': lock.fileName,
      'tokens': _sorted(lock.tokens),
      'typography': _sorted(lock.typography),
      'components': _sorted(lock.components),
      'icons': _sorted(lock.icons),
      'symbols': LockSymbols.toJson(lock.symbols),
      'deprecated': LockSymbols.toJson(lock.deprecated),
    };
    return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
  }

  static Map<String, String> _sorted(Map<String, String> map) => {
    for (final key in map.keys.toList()..sort()) key: map[key]!,
  };

  static Map<String, String> _strings(Object? value) {
    if (value is! Map) return const {};
    return {for (final e in value.entries) '${e.key}': '${e.value}'};
  }
}
