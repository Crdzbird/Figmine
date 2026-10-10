import 'package:figmine/src/config/config_exception.dart';

/// The settings each section of `figmine.yaml` accepts.
abstract final class ConfigKeys {
  static const Map<String, Set<String>> _sections = {
    'figmine': {
      'figma',
      'tokens',
      'colors',
      'color_scheme',
      'typography',
      'inference',
      'library',
      'icons',
      'output',
      'lock_file',
      'components',
    },
    'figmine.figma': {'file_key', 'token_env'},
    'figmine.tokens': {
      'source',
      'files',
      'collections',
      'strip_prefix',
      'light_mode',
      'dark_mode',
    },
    'figmine.color_scheme': {
      'collection',
      'seed',
      'roles',
      'extra',
      'overrides',
    },
    'figmine.typography': {'enabled', 'strip_prefix', 'roles'},
    'figmine.inference': {
      'mode',
      'pages',
      'exclude_pages',
      'node_ids',
      'max_frames',
    },
    'figmine.library': {'file_keys', 'team_id'},
    'figmine.icons': {'node_ids', 'name_prefix', 'output'},
    'figmine.output': {
      'directory',
      'theme_directory',
      'class_prefix',
      'material_import',
      'layout',
    },
  };

  /// Throws when [map] of [section] has a key figmine does not know,
  /// naming the section the key belongs to when there is one.
  static void check(String section, Map<Object?, Object?> map) {
    final known =
        _sections[section.replaceFirst('figmine.colors', 'figmine.tokens')];
    if (known == null) return;
    for (final key in map.keys.map((k) => '$k')) {
      if (known.contains(key)) continue;
      final home = _sections.entries
          .where((e) => e.key != 'figmine' && e.value.contains(key))
          .map((e) => '`${e.key.substring(8)}.$key`')
          .join(' or ');
      final label = section == 'figmine' ? key : '${section.substring(8)}.$key';
      throw ConfigException(
        '`$label` is not a figmine setting.'
        '${home.isEmpty ? '' : ' Did you mean $home?'}',
      );
    }
  }
}
