import 'package:figmine/src/lock/lock_snapshot.dart';
import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Snapshot of the last generated tokens, committed next to the code.
final class LockFile {
  /// Creates a lock snapshot.
  const factory({
    required String fileKey,
    required String version,
    required String lastModified,
    String fileName,
    Map<String, String> tokens,
    Map<String, String> typography,
    Map<String, String> components,
    Map<String, String> icons,
    Map<String, LockSymbol> symbols,
    Map<String, LockSymbol> deprecated,
  }) = LockFile._;

  const new _({
    required this.fileKey,
    required this.version,
    required this.lastModified,
    this.fileName = '',
    this.tokens = const {},
    this.typography = const {},
    this.components = const {},
    this.icons = const {},
    this.symbols = const {},
    this.deprecated = const {},
  });

  /// Captures [set] read from [fileKey], with the generated [symbols].
  factory of(
    String fileKey,
    TokenSet set, {
    Map<String, LockSymbol> symbols = const {},
  }) => LockFile(
    fileKey: fileKey,
    version: set.meta.version,
    lastModified: set.meta.lastModified,
    fileName: set.meta.name,
    tokens: LockSnapshot.tokens(set),
    typography: LockSnapshot.typography(set),
    components: LockSnapshot.components(set),
    icons: LockSnapshot.icons(set),
    symbols: symbols,
  );

  /// The Figma file key.
  final String fileKey;

  /// Figma version that produced the snapshot.
  final String version;

  /// Last edit time of that version.
  final String lastModified;

  /// Name of the Figma file, empty in older lock files.
  final String fileName;

  /// Tokens keyed by `collection/path`.
  final Map<String, String> tokens;

  /// Text styles keyed by name.
  final Map<String, String> typography;

  /// Component dimensions keyed by name.
  final Map<String, String> components;

  /// Icon names mapped to the SHA-256 of their SVG.
  final Map<String, String> icons;

  /// Every generated constant, keyed as `Class.member`.
  final Map<String, LockSymbol> symbols;

  /// Constants removed from Figma, kept because code still uses them.
  final Map<String, LockSymbol> deprecated;

  /// A copy that keeps [kept] as deprecated constants.
  LockFile withDeprecated(Map<String, LockSymbol> kept) => LockFile(
    fileKey: fileKey,
    version: version,
    lastModified: lastModified,
    fileName: fileName,
    tokens: tokens,
    typography: typography,
    components: components,
    icons: icons,
    symbols: symbols,
    deprecated: kept,
  );
}
