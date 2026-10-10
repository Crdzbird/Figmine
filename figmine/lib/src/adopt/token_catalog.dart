import 'package:figmine/src/adopt/literal.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/literal_usage.dart';
import 'package:figmine/src/adopt/role_preference.dart';
import 'package:figmine/src/adopt/suggestion.dart';
import 'package:figmine/src/adopt/token_rank.dart';
import 'package:figmine/src/lock/lock_symbol.dart';

/// The generated constants of a project, by value, to replace literals.
final class TokenCatalog {
  /// Creates a catalog of [symbols] from the lock file, with the scheme
  /// [roles] by light color and the BuildContext [getter] of the scheme.
  factory(
    Map<String, LockSymbol> symbols, {
    Map<int, List<String>> roles,
    String getter,
  }) = TokenCatalog._;

  new _(this.symbols, {this.roles = const {}, this.getter = 'colors'});

  /// Generated constants by name, such as `AppSpace.v16`.
  final Map<String, LockSymbol> symbols;

  /// Color scheme fields by their light color, Material roles first.
  final Map<int, List<String>> roles;

  /// The BuildContext getter of the color scheme.
  final String getter;

  static final Map<LiteralKind, RegExp> _names = {
    LiteralKind.spacing: RegExp('space|spacing|gap|padding|margin|inset'),
    LiteralKind.radius: RegExp('radius|corner|round'),
  };

  static final RegExp _lightMode = RegExp('light|default|value|mobile');

  /// The tokens for [literal], best first. Colors prefer tokens and roles
  /// meant for their use, such as `Text/...` inside a `TextStyle`.
  Suggestion suggest(Literal literal) {
    final usage = LiteralUsage.of(literal.owner, literal.property);
    final fit = RegExp(_fit(literal, usage));
    List<int> rank(LockSymbol s) =>
        TokenRank.of(s, misfit: !fit.hasMatch(s.token.toLowerCase()));

    final ranked = [
      for (final entry in symbols.entries)
        if (_matches(literal, entry.value)) entry,
    ]..sort((a, b) => TokenRank.compare(rank(a.value), rank(b.value)));
    final best = ranked.firstOrNull;
    final tie =
        ranked.length > 1 &&
        TokenRank.compare(rank(ranked[0].value), rank(ranked[1].value)) == 0;
    final fields = literal.kind == LiteralKind.color
        ? roles[literal.value] ?? const <String>[]
        : const <String>[];
    final role = RolePreference.pick(fields, usage);
    return (
      literal: literal,
      constant: tie ? null : best?.key,
      others: [for (final e in ranked.skip(tie ? 0 : 1)) e.key],
      themed: role == null ? null : 'context.$getter.$role',
    );
  }

  /// Token names meant for [literal]: by color use, padding inside
  /// `EdgeInsets`, gaps inside `SizedBox`, or any radius.
  static String _fit(Literal literal, LiteralUsage usage) =>
      switch (literal.kind) {
        LiteralKind.color => usage.tokens,
        LiteralKind.spacing
            when literal.owner?.startsWith('EdgeInsets') ?? false =>
          'padding|inset',
        LiteralKind.spacing => 'gap|spacing|space',
        LiteralKind.radius => 'radius|corner|round',
      };

  bool _matches(Literal literal, LockSymbol symbol) {
    final mode = symbol.mode?.toLowerCase();
    if (mode != null && !_lightMode.hasMatch(mode)) return false;
    if (literal.kind == LiteralKind.color) {
      return symbol.type == 'Color' && _argb(symbol.value) == literal.value;
    }
    if (literal.value == 0 || symbol.type != 'double') return false;
    final name = symbol.token.toLowerCase();
    return _names[literal.kind]!.hasMatch(name) &&
        num.tryParse(symbol.value) == literal.value;
  }

  static int? _argb(String value) {
    final hex = RegExp('0x([0-9A-Fa-f]{8})').firstMatch(value)?.group(1);
    return hex == null ? null : int.parse(hex, radix: 16);
  }
}
