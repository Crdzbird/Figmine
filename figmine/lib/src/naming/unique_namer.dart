/// Hands out names that are unique within one scope.
final class UniqueNamer {
  /// Creates an empty scope.
  factory() = UniqueNamer._;

  new _();

  final Set<String> _taken = {};

  /// Whether [name] was already claimed.
  bool taken(String name) => _taken.contains(name);

  /// Returns [base], or [base] with a numeric suffix when already taken.
  String claim(String base) {
    var candidate = base;
    var suffix = 2;
    while (_taken.contains(candidate)) {
      candidate = '$base$suffix';
      suffix++;
    }
    _taken.add(candidate);
    return candidate;
  }
}
