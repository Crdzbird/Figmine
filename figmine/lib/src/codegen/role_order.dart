import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Keeps text roles of one kind in size order.
abstract final class RoleOrder {
  static const List<String> _sizes = ['Large', 'Medium', 'Small'];

  /// [roles] with the styles of each kind, such as `bodyLarge`,
  /// `bodyMedium` and `bodySmall`, sorted so larger roles get larger
  /// styles.
  static Map<String, TextStyleToken> sorted(Map<String, TextStyleToken> roles) {
    final result = {...roles};
    final kinds = {
      for (final role in MaterialRoles.textTheme)
        role.replaceAll(RegExp(r'(Large|Medium|Small)$'), ''),
    };
    for (final kind in kinds) {
      final names = [
        for (final size in _sizes)
          if (roles.containsKey('$kind$size')) '$kind$size',
      ];
      final styles = [for (final n in names) roles[n]!]
        ..sort((a, b) => b.fontSize.compareTo(a.fontSize));
      for (var i = 0; i < names.length; i++) {
        result[names[i]] = styles[i];
      }
    }
    return result;
  }
}
