import 'package:figmine/src/figma/json.dart';

/// A generated constant: the token behind it and how to recreate it.
typedef LockSymbol = ({
  String token,
  String? mode,
  String type,
  String value,
  String? id,
});

/// Reads and writes symbol tables of the lock file.
abstract final class LockSymbols {
  /// Encodes [symbols] sorted by name.
  static Map<String, Object?> toJson(Map<String, LockSymbol> symbols) => {
    for (final name in symbols.keys.toList()..sort())
      name: {
        'token': symbols[name]!.token,
        'mode': ?symbols[name]!.mode,
        'type': symbols[name]!.type,
        'value': symbols[name]!.value,
        'id': ?symbols[name]!.id,
      },
  };

  /// Decodes a table written by [toJson].
  static Map<String, LockSymbol> fromJson(Object? json) => {
    for (final entry in Json.map(json).entries)
      if (Json.map(entry.value) case final s when s['token'] is String)
        entry.key: (
          token: s['token']! as String,
          mode: s['mode'] as String?,
          type: '${s['type'] ?? 'Object'}',
          value: '${s['value'] ?? ''}',
          id: s['id'] as String?,
        ),
  };
}
