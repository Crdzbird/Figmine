import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_metrics.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/sample_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/figma_nodes.dart';

ComponentSample _tooltip(String family, int fill) => (
  kind: ComponentKind.tooltip,
  name: '$family tooltip',
  instance: true,
  definition: false,
  family: family,
  fill: fill,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: null,
  labelVariable: null,
  radius: 4,
  pill: false,
  height: 32,
  paddingHorizontal: null,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('overlays, fabs and bottom bars are their own kinds', () {
    expect(ComponentKind.match('Tooltip placement=top'), ComponentKind.tooltip);
    expect(ComponentKind.match('toast-alert'), ComponentKind.snackbar);
    expect(ComponentKind.match('FAB hierarchy=primary'), ComponentKind.fab);
    expect(
      ComponentKind.match('Bottom Navigation'),
      ComponentKind.navigationBar,
    );
    expect(
      ComponentKind.match('Dialog Body Type=Sheet'),
      ComponentKind.bottomSheet,
    );
    expect(
      ComponentKind.match('Modal breakpoint=mobile'),
      ComponentKind.dialog,
    );
    expect(ComponentKind.match('banner-alert'), isNull);
    expect(ComponentKind.match('navbar'), ComponentKind.appBar);
  });

  test('a component named for the kind beats layers named for it', () {
    final samples = [
      for (var i = 0; i < 5; i++) _tooltip('icon', 0xFF0000FF),
      for (var i = 0; i < 3; i++) _tooltip('tooltip', 0xFF1B115C),
    ];
    final picked = ComponentSamples.select(ComponentKind.tooltip, samples);
    expect(picked.samples.map((s) => s.fill).toSet(), {0xFF1B115C});
  });

  test('the scrim of a dialog is not its fill', () {
    final scrim = box(
      '1',
      fill: 0xFFFFFF,
      height: 800,
      children: [box('2', fill: 0xF4F4F4, radius: 24, height: 300)],
    );
    ((scrim['fills']! as List).single as Map)['opacity'] = 0.8;
    final dialog = SampleReader.read(scrim, ComponentKind.dialog);
    expect((dialog.fill, dialog.radius), (0xFFF4F4F4, 24.0));
    final card = SampleReader.read(scrim, ComponentKind.card);
    expect(card.height, 800);
  });

  test('missing components fall back to Material metrics', () {
    final metrics = ComponentMetrics.infer(const []);
    expect(metrics['fabSize']!.value, 56);
    expect(metrics['dialogRadius']!.value, 28);
    expect(metrics['navigationBarHeight']!.doc, contains('no navigationBar'));
  });
}
