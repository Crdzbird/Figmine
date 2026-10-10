import 'package:figmine/src/lock/lock_symbol.dart';

/// Orders tokens that share a value, best first.
abstract final class TokenRank {
  static final RegExp _default = RegExp(r'^(default|base|regular|idle)$');

  static final RegExp _primitive = RegExp(
    r'primitive|palette|brand-colors|(^|/)_?core(/|$)',
  );

  /// The rank of [symbol], lower is better: tokens meant for the use
  /// unless [misfit], then real tokens before inferred ones, semantic
  /// before primitive, single mode before per mode, default variants such
  /// as `Text/Danger/Default` before others, and shorter paths.
  static List<int> of(LockSymbol symbol, {bool misfit = false}) {
    final token = symbol.token.toLowerCase();
    final flags = [
      misfit,
      token.startsWith('inferred'),
      _primitive.hasMatch(token),
      symbol.mode != null,
      !_default.hasMatch(token.split('/').last),
    ];
    return [...flags.map((f) => f ? 1 : 0), symbol.token.split('/').length];
  }

  /// Compares two ranks of [of].
  static int compare(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i] - b[i];
    }
    return 0;
  }
}
