import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/dtcg/dtcg_builder.dart';
import 'package:figmine/src/sources/dtcg/dtcg_files.dart';
import 'package:figmine/src/sources/dtcg/dtcg_reader.dart';

/// Reads tokens from design token files, when the configuration asks for
/// them.
abstract final class FileTokens {
  /// Tokens from `tokens.files`, or null when files are not the source.
  static Future<DtcgTokens?> load(String root, TokensConfig config) async {
    final useFiles =
        config.source == TokenSource.file ||
        (config.source == TokenSource.auto && config.files.isNotEmpty);
    if (!useFiles) return null;
    final files = await DtcgFiles.load(root, config.files);
    return DtcgBuilder.build(
      files.expand(DtcgReader.entries).toList(),
      DtcgReader.modes(files),
      config,
    );
  }
}
