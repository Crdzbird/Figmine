import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/sample_reader.dart';
import 'package:figmine/src/screens/screen_set.dart';

/// Recognizes the component a layer of the screens is.
abstract final class NodeKind {
  /// The kind, full name and component of [node]: an instance, a variant
  /// of the component [set] it is defined in, or a lookalike button.
  static (ComponentKind, String, String?)? of(
    ScreenSet screens,
    Map<String, Object?> node,
    String? set,
  ) {
    if (node['type'] == 'COMPONENT' && set != null) {
      final name = '$set ${node['name']}';
      final kind = ComponentKind.match(name);
      if (kind != null) return (kind, name, set);
    }
    if (node['type'] == 'INSTANCE') {
      final component = screens.components['${node['componentId']}'];
      final set = screens.componentSets['${component?['componentSetId']}'];
      final name = [set?['name'], component?['name'], node['name']].join(' ');
      final kind = ComponentKind.match(name);
      final family = '${set?['name'] ?? component?['name']}';
      if (kind != null) return (kind, name, family);
    }
    if (SampleReader.looksLikeButton(node)) {
      return (ComponentKind.button, '${node['name']}', null);
    }
    return null;
  }
}
