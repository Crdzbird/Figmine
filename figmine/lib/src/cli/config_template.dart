/// The `figmine.yaml` written by `figmine init`.
abstract final class ConfigTemplate {
  /// Returns the template for the file [key], reading tokens from
  /// [source], analyzing screens in [inference] mode, with classes named
  /// after [prefix]. The `file` source lists `design-tokens.json`.
  static String render(
    String key, {
    String source = 'auto',
    String inference = 'auto',
    String prefix = 'App',
  }) =>
      '''
figma:
  file_key: $key
  token_env: FIGMA_TOKEN

tokens:
  source: $source
  files: [${source == 'file' ? 'design-tokens.json' : ''}]
  collections: {}
  strip_prefix: ""
  light_mode: light
  dark_mode: dark

color_scheme:
  roles: {}
  extra: {}
  overrides: {}

typography:
  enabled: true
  roles: {}

inference:
  mode: ${inference == 'off' ? '"off"' : inference}
  pages: []
  node_ids: []

library:
  file_keys: []

icons:
  node_ids: []
  name_prefix: ""
  output: assets/figmine/icons

output:
  directory: lib/theme/tokens
  theme_directory: lib/theme
  class_prefix: $prefix
  layout: domain

components: {}

lock_file: figmine.lock.json
''';
}
