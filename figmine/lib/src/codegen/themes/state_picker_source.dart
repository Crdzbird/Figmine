import 'package:figmine/src/codegen/emit/codegen_context.dart';

/// Source of the generated class that picks the color of a set of widget
/// states, shared by the button and control themes.
abstract final class StatePickerSource {
  /// The library of the state picker of [context].
  static String render(CodegenContext context) =>
      '''
${context.header(imports: [context.materialImport])}
/// Picks the color for a set of widget states.
abstract final class ${context.statePickerClass} {
  /// The color of [states]: disabled first, then pressed, focused and
  /// hovered, or [rest].
  static Color of(
    Set<WidgetState> states,
    Color rest,
    Color hovered,
    Color pressed,
    Color focused,
    Color disabled,
  ) {
    if (states.contains(WidgetState.disabled)) return disabled;
    if (states.contains(WidgetState.pressed)) return pressed;
    if (states.contains(WidgetState.focused)) return focused;
    if (states.contains(WidgetState.hovered)) return hovered;
    return rest;
  }
}
''';
}
