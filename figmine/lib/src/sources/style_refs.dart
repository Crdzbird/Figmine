import 'package:figmine/src/config/library_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/style_ref.dart';

/// Lists the styles figmine reads, from every source the token allows.
final class StyleRefs {
  /// Creates a lister that reads with [client].
  const factory({
    required FigmaClient client,
    required LibraryConfig library,
    required void Function(String message) log,
  }) = StyleRefs._;

  const new _({required this.client, required this.library, required this.log});

  /// The Figma client.
  final FigmaClient client;

  /// Library files and team.
  final LibraryConfig library;

  /// Receives progress messages.
  final void Function(String message) log;

  /// Style types figmine reads.
  static const Set<String> types = {'FILL', 'TEXT', 'EFFECT'};

  /// Published styles of [fileKey], null without `library_content:read`.
  Future<List<StyleRef>?> published(String fileKey) async {
    try {
      final json = await client.getJson('/v1/files/$fileKey/styles');
      return _list(Json.list(Json.map(json['meta'])['styles']), fileKey);
    } on FigmaException catch (error) {
      if (error.statusCode != 403 && error.statusCode != 404) rethrow;
      return null;
    }
  }

  /// Styles of the configured library files and team.
  Future<List<StyleRef>> libraries() async {
    final refs = <StyleRef>[];
    for (final key in library.fileKeys) {
      final styles = await published(key);
      if (styles == null) {
        log('Cannot read library $key: library_content:read.');
      }
      refs.addAll(styles ?? const []);
    }
    final team = library.teamId;
    if (team != null) refs.addAll(await _team(team));
    return refs;
  }

  /// Resolves a remote style used by the screens, by its [key]. Returns
  /// null without `library_assets:read`.
  Future<StyleRef?> remote(String key) async {
    try {
      final json = await client.getJson('/v1/styles/$key');
      final list = _list([Json.map(json['meta'])], '');
      return list.isEmpty ? null : list.single;
    } on FigmaException catch (error) {
      if (error.statusCode != 403 && error.statusCode != 404) rethrow;
      return null;
    }
  }

  Future<List<StyleRef>> _team(String team) async {
    final refs = <StyleRef>[];
    var query = {'page_size': '1000'};
    while (true) {
      final Map<String, Object?> meta;
      try {
        final json = await client.getJson('/v1/teams/$team/styles', query);
        meta = Json.map(json['meta']);
      } on FigmaException catch (error) {
        if (error.statusCode != 403) rethrow;
        log('Cannot read team $team: team_library_content:read.');
        return refs;
      }
      refs.addAll(_list(Json.list(meta['styles']), ''));
      final after = Json.map(meta['cursor'])['after'];
      if (after == null || Json.list(meta['styles']).isEmpty) return refs;
      query = {'page_size': '1000', 'after': '$after'};
    }
  }

  static List<StyleRef> _list(List<Object?> styles, String fileKey) => [
    for (final style in styles.map(Json.map))
      if (types.contains(style['style_type']))
        (
          name: '${style['name']}',
          type: '${style['style_type']}',
          fileKey: '${style['file_key'] ?? fileKey}',
          nodeId: '${style['node_id']}',
          description: '${style['description'] ?? ''}',
        ),
  ];
}
