import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/index_namer.dart';
import 'package:figmine/src/codegen/emit/token_address.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Assigns a class, constant and file to every token in every mode.
///
/// Each collection gets a folder, and each group a class in its own file,
/// one per mode when there are several. The configured light and dark
/// modes are named `Light` and `Dark`, such as Figma's `SDS Light`.
final class TokenIndex {
  /// Indexes [collections] for classes named with [prefix].
  ///
  /// Files come from [layout]. Class names in [reservedClasses] are never
  /// handed out; colliding names get a `Tokens` suffix.
  factory({
    required List<TokenCollection> collections,
    required String prefix,
    required TokensConfig config,
    FileLayout? layout,
    Set<String> reservedClasses,
  }) = TokenIndex._;

  new _({
    required List<TokenCollection> collections,
    required this.prefix,
    required this.config,
    FileLayout? layout,
    Set<String> reservedClasses = const {},
  }) : _layout = layout ?? FileLayout(),
       _namer = IndexNamer(prefix: prefix, reservedClasses: reservedClasses) {
    collections.forEach(_add);
  }

  /// Prefix of every class name.
  final String prefix;

  /// Token settings with the collection name segments.
  final TokensConfig config;

  /// Folder of each collection, by collection name.
  final Map<String, String> folderOf = {};

  /// Every token in every mode, in generation order.
  final List<IndexEntry> entries = [];

  final FileLayout _layout;
  final IndexNamer _namer;
  final Map<String, TokenAddress> _addresses = {};
  final Map<String, String> _files = {};

  /// The address of [name] in [collection] and [mode], which any [mode]
  /// finds in a single mode collection.
  TokenAddress? find(String collection, String name, String? mode) {
    final exact = _addresses['$collection|$name|$mode'];
    if (exact != null) return exact;
    final all = _addresses.entries
        .where((e) => e.key.startsWith('$collection|$name|'))
        .toList();
    return all.length == 1 ? all.single.value : null;
  }

  /// The library of the declaration [name] in the folder of [collection].
  String libraryOf(String collection, String name) =>
      _files[name] ??= _layout.library(folderOf[collection]!, name);

  void _add(TokenCollection collection) {
    final segment = config.segmentOf(collection.name);
    final folder = _layout.collection(collection);
    folderOf[collection.name] = folder;
    final picked = CollectionModes.pick(collection.modes, config);
    String label(String mode) => mode == picked.light && mode != picked.dark
        ? 'Light'
        : (mode == picked.dark && mode != picked.light ? 'Dark' : mode);
    for (final token in collection.tokens) {
      for (final mode in collection.modes) {
        final className = _namer.type(
          '${collection.name}|${token.group.join('/')}|$mode',
          [segment, ...token.group, if (collection.multiMode) label(mode)],
        );
        final address = (
          className: className,
          member: _namer.member(className, token.leaf),
          file: libraryOf(collection.name, className),
        );
        _addresses['${collection.name}|${token.name}|$mode'] = address;
        entries.add((
          collection: collection,
          token: token,
          mode: mode,
          address: address,
        ));
      }
    }
  }
}
