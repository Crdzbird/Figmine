import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/pipeline/token_assembler.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/tokens/token_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';
import '../../helpers/screens_fixture.dart';

ScreenSet _screens() {
  final entry = (screenNodesJson['nodes']! as Map)['1:1']! as Map;
  return ScreenSet(
    frames: [
      (page: 'App', node: (entry['document']! as Map).cast<String, Object?>()),
    ],
  );
}

TokenSet _assemble(InferenceMode mode) =>
    TokenAssembler(
      config: FigmineConfig(
        fileKey: 'K',
        inference: InferenceConfig(mode: mode),
      ),
      log: (_) {},
    ).assemble(
      meta: sampleMeta,
      collections: sampleTokens.collections,
      styles: const [],
      screens: _screens(),
      icons: const [],
    );

void main() {
  test('auto keeps defined colors and always adds layout', () {
    final names = _assemble(InferenceMode.auto).collections.map((c) => c.name);
    expect(names, ['Primitives', 'Semantic', 'Inferred layout']);
  });

  test('always adds inferred colors next to defined ones', () {
    final set = _assemble(InferenceMode.always);
    expect(set.collections.map((c) => c.name), contains('Inferred colors'));
    expect(set.textStyles, isNotEmpty);
    expect(set.components['buttonHeight']!.value, 48);
  });
}
