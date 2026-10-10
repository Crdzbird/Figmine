import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/doc_comment.dart';
import 'package:figmine/src/inference/metric_specs.dart';
import 'package:figmine/src/tokens/component_metric.dart';

/// Writes the component dimensions measured in the screens.
abstract final class ComponentsWriter {
  static const String _summary =
      'Component dimensions measured in the designed screens: the most '
      'common value across instances, or the Material default.';

  /// Returns the library source. Missing metrics use Material defaults.
  static String write(
    CodegenContext context,
    Map<String, ComponentMetric> metrics,
  ) {
    final buffer = StringBuffer(context.header())
      ..writeln()
      ..write(DocComment.render([_summary]))
      ..writeln('abstract final class ${context.componentsClass} {');
    for (final name in MetricSpecs.defaults.keys) {
      final metric =
          metrics[name] ??
          (
            value: MetricSpecs.defaults[name]!,
            doc: 'Material default: screens were not analyzed.',
          );
      buffer
        ..write(DocComment.render([metric.doc], indent: 2))
        ..writeln(
          '  static const double $name = ${DartSource.number(metric.value)};',
        )
        ..writeln();
    }
    return (buffer..writeln('}')).toString();
  }
}
