import 'package:figmine/src/codegen/states/state_field_specs.dart';

/// Groups the component state fields of the scheme by component, such as
/// `buttonHovered` into the `hovered` member of the `button` group.
abstract final class StateGroups {
  static final Map<String, String> _kinds = {
    for (final spec in StateFieldSpecs.all) spec.name: spec.key.split('.')[0],
  };

  /// Every component, in the order of its first field.
  static final List<String> kinds = {..._kinds.values}.toList();

  /// The component of the state field [name], or null for a scheme role.
  static String? kindOf(String name) => _kinds[name];

  /// The getter of the group of [kind] on the scheme, `toggle` for
  /// switches since `switch` is a keyword.
  static String accessor(String kind) => kind == 'switch' ? 'toggle' : kind;

  /// The component of the group read with [accessor].
  static String kindOfAccessor(String accessor) =>
      accessor == 'toggle' ? 'switch' : accessor;

  /// The class of the group of [kind], such as `AppButtonColors`.
  static String className(String prefix, String kind) =>
      '$prefix${_upper(kind)}Colors';

  /// The member of the state field [name] in the group of [kind]: `color`
  /// and `onColor` for the resting fill and label, otherwise the name
  /// without the component, such as `hovered` and `onHovered`.
  static String member(String name, String kind) {
    final on = 'on${_upper(kind)}';
    if (name.startsWith(on)) {
      final rest = name.substring(on.length);
      return rest.isEmpty ? 'onColor' : 'on$rest';
    }
    final rest = name.substring(kind.length);
    return rest.isEmpty
        ? 'color'
        : '${rest[0].toLowerCase()}${rest.substring(1)}';
  }

  /// The state field of [member] in the group of [kind], the inverse of
  /// [member].
  static String field(String kind, String member) {
    if (member == 'color') return kind;
    if (member == 'onColor') return 'on${_upper(kind)}';
    if (RegExp('^on[A-Z]').hasMatch(member)) {
      return 'on${_upper(kind)}${member.substring(2)}';
    }
    return '$kind${_upper(member)}';
  }

  static String _upper(String s) => '${s[0].toUpperCase()}${s.substring(1)}';
}
