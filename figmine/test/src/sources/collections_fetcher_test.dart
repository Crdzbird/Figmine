import 'package:figmine/src/config/token_source.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/sources/collections_fetcher.dart';
import 'package:figmine/src/sources/variables_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/style_catalog_helper.dart';
import '../../helpers/styles_fixture.dart';
import '../../helpers/variables_fixture.dart';

CollectionsFetcher _fetcher(
  FigmaClient client,
  TokenSource source,
  List<String> logs,
) => CollectionsFetcher(
  config: TokensConfig(source: source),
  variables: VariablesSource(client: client, config: const TokensConfig()),
  styles: () => styleCatalog(client).fetch('KEY'),
  log: logs.add,
);

void main() {
  const styles = {'/v1/files/KEY': fileJson};

  group(CollectionsFetcher, () {
    test('auto uses variables when they have colors', () async {
      final client = fakeFigma(
        json: {'/v1/files/KEY/variables/local': variablesJson},
      );
      final result = await _fetcher(client, TokenSource.auto, []).fetch('KEY');
      expect(result.map((c) => c.name), ['Primitives', 'Semantic']);
    });

    test('auto falls back to styles when variables are forbidden', () async {
      final logs = <String>[];
      final client = fakeFigma(
        json: {...styles, '/v1/files/KEY/nodes': styleNodesJson},
        errors: {'/v1/files/KEY/variables/local': 403},
      );
      final result = await _fetcher(
        client,
        TokenSource.auto,
        logs,
      ).fetch('KEY');
      expect(result.single.name, 'Styles');
      expect(logs.single, contains('403'));
    });

    test('variables source surfaces the error', () async {
      final client = fakeFigma(errors: {'/v1/files/KEY/variables/local': 403});
      expect(
        _fetcher(client, TokenSource.variables, []).fetch('KEY'),
        throwsA(isA<FigmaException>()),
      );
    });

    test('auto rethrows server errors', () async {
      final client = fakeFigma(errors: {'/v1/files/KEY/variables/local': 500});
      expect(
        _fetcher(client, TokenSource.auto, []).fetch('KEY'),
        throwsA(isA<FigmaException>()),
      );
    });
  });
}
