/// Figma personal access token scopes that figmine can use.
enum FigmaScope {
  /// `current_user:read`: identifies the token owner.
  currentUserRead('current_user:read', 'figmine doctor identity'),

  /// `file_content:read`: screens, styles, icons and inference.
  fileContentRead('file_content:read', 'screens, styles, icons, inference'),

  /// `file_metadata:read`: the cheap version check.
  fileMetadataRead('file_metadata:read', 'fast version check'),

  /// `file_versions:read`: version history in pull requests.
  fileVersionsRead('file_versions:read', 'version history in pull requests'),

  /// `file_variables:read`: Figma Variables, Enterprise only.
  fileVariablesRead('file_variables:read', 'variables (Enterprise only)'),

  /// `library_content:read`: published styles of a file.
  libraryContentRead('library_content:read', 'published styles of files'),

  /// `team_library_content:read`: styles of a team library.
  teamLibraryContentRead('team_library_content:read', 'team library styles'),

  /// `library_assets:read`: library styles used by screens.
  libraryAssetsRead('library_assets:read', 'library styles used in screens'),

  /// `webhooks:read`: listing webhooks.
  webhooksRead('webhooks:read', 'figmine webhook list'),

  /// `webhooks:write`: creating and deleting webhooks.
  webhooksWrite('webhooks:write', 'figmine webhook create and delete'),

  /// `file_comments:write`: pull request links in Figma comments.
  fileCommentsWrite('file_comments:write', 'figmine comment');

  new(this.id, this.enables);

  /// The scope id shown in Figma.
  final String id;

  /// What figmine does with the scope.
  final String enables;
}
