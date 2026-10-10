import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/score/inferred_snapshot.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screens_fixture.dart';

void main() {
  test('screens alone are graded on the full derived scheme', () {
    final nodes = (screenNodesJson['nodes']! as Map).cast<String, Object?>();
    final light = nodes['1:1']! as Map<String, Object?>;
    final result = DesignInference.analyze(
      ScreenSet(
        frames: [
          (page: 'App', node: light['document']! as Map<String, Object?>),
        ],
      ),
      const TokensConfig(),
    );
    final names = {
      for (final f in InferredSnapshot.scheme(result, const TokensConfig()))
        f.name,
    };
    expect(result.colors!.find('primaryContainer'), isNull);
    expect(
      names,
      containsAll([
        'primary',
        'primaryContainer',
        'onSurfaceVariant',
        'outlineVariant',
      ]),
    );
  });
}
