/// The `figmine.yaml` written by `figmine init`.
abstract final class ConfigTemplate {
  /// Returns the template for the file [key].
  static String render(String key) =>
      '''
figma:
  file_key: $key
  token_env: FIGMA_TOKEN

tokens:
  source: auto
  files: []
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
  mode: auto
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
  class_prefix: App
  layout: domain

components: {}

lock_file: figmine.lock.json
''';
}
