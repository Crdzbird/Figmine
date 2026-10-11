import 'package:figmine/src/inference/component_kind.dart';

/// Measurements of one component instance found in the screens.
typedef ComponentSample = ({
  ComponentKind kind,
  String name,
  bool instance,
  bool definition,
  String family,
  int? fill,
  String? fillVariable,
  int? stroke,
  String? strokeVariable,
  int? label,
  String? labelVariable,
  double? radius,
  bool pill,
  double height,
  double? paddingHorizontal,
  double? padding,
  double shadow,
  int? mark,
  String? markVariable,
});
