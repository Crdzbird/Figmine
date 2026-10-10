import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/json.dart';

/// What a Figma file offers figmine, from light reads only.
typedef FileOffer = ({String? name, int? variables, int? styles});

/// Probes a file without the heavy file read, to keep the API budget.
abstract final class FileOffers {
  /// The file name, how many local variables the token can read, or null
  /// when it cannot, and how many styles the file publishes.
  static Future<FileOffer> probe(FigmaClient client, String key) async {
    final file = '/v1/files/$key';
    Future<Map<String, Object?>?> get(String path) async {
      try {
        return await client.getJson(path);
      } on FigmaException {
        return null;
      }
    }

    final meta = await get('$file/meta');
    final variables = await get('$file/variables/local');
    final styles = await get('$file/styles');
    final name = Json.map(meta?['file'])['name'];
    return (
      name: name is String ? name : null,
      variables: variables == null
          ? null
          : Json.map(Json.map(variables['meta'])['variables']).length,
      styles: styles == null
          ? null
          : Json.list(Json.map(styles['meta'])['styles']).length,
    );
  }
}
