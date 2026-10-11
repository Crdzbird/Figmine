import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('implausible measurements fall back to the Material default', () {
    final metrics = ComponentMetrics.infer([
      for (final height in [370.0, 370.0, 480.0])
        (
          kind: ComponentKind.appBar,
          name: 'header',
          instance: true,
          definition: false,
          family: 'header',
          fill: null,
          fillVariable: null,
          stroke: null,
          strokeVariable: null,
          label: null,
          labelVariable: null,
          radius: null,
          pill: false,
          height: height,
          paddingHorizontal: null,
          padding: null,
          shadow: 0,
          mark: null,
          markVariable: null,
        ),
    ]);
    expect(metrics['appBarHeight']!.value, 64);
    expect(metrics['appBarHeight']!.doc, contains('outside 40 to 128'));
  });
}
