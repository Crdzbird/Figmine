import 'package:figmine/src/config/library_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/sources/style_catalog.dart';
import 'package:figmine/src/sources/style_refs.dart';

/// A style catalog over [client] without libraries.
StyleCatalog styleCatalog(FigmaClient client) => StyleCatalog(
  client: client,
  refs: StyleRefs(client: client, library: const LibraryConfig(), log: (_) {}),
);
