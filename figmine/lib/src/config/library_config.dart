import 'package:figmine/src/config/yaml_reader.dart';

/// The `library` section of `figmine.yaml`.
final class LibraryConfig {
  /// Creates library settings.
  const factory({List<String> fileKeys, String? teamId}) = LibraryConfig._;

  const new _({this.fileKeys = const [], this.teamId});

  /// Reads the section from YAML.
  factory fromYaml(YamlReader yaml) => LibraryConfig(
    fileKeys: yaml.strings('file_keys'),
    teamId: yaml.string('team_id'),
  );

  /// Design system files whose published styles are read.
  final List<String> fileKeys;

  /// Team whose library styles are read, from `figma.com/files/team/<id>`.
  final String? teamId;

  /// Whether any library is configured.
  bool get isEmpty => fileKeys.isEmpty && teamId == null;
}
