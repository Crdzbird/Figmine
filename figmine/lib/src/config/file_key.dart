/// Extracts and checks Figma file keys.
abstract final class FileKey {
  static final RegExp _url = RegExp(
    r'figma\.com/(?:file|design|proto|board|slides|deck|make)/'
    '([A-Za-z0-9]+)(?:/branch/([A-Za-z0-9]+))?',
  );

  static final RegExp _token = RegExp(r'^fig[a-z]_|^fig[a-z]$');

  static final RegExp _key = RegExp(r'^[A-Za-z0-9]{10,}$');

  /// Returns the key in [input], which may be a full Figma link.
  ///
  /// Branch links return the branch key, which the API accepts as a file.
  static String parse(String input) {
    final match = _url.firstMatch(input);
    if (match == null) return input.trim();
    return match.group(2) ?? match.group(1)!;
  }

  /// Why [key] cannot be a file key, or null when it looks valid.
  ///
  /// Never repeats a value that looks like an access token.
  static String? problem(String key) {
    if (_token.hasMatch(key)) {
      return 'The file key looks like a Figma access token. Keep the token '
          'in FIGMA_TOKEN and set figma.file_key to the file URL or key.';
    }
    if (key == 'YOUR_FILE_KEY') {
      return 'figma.file_key is still the placeholder. Set it to the URL of '
          'your Figma file.';
    }
    if (_key.hasMatch(key)) return null;
    return '"$key" is not a Figma file key. Copy the file URL, '
        'https://www.figma.com/design/<key>/<name>, into figma.file_key.';
  }
}
