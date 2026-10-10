/// Safe casts for decoded JSON.
abstract final class Json {
  /// Returns [value] as a map, or an empty map.
  static Map<String, Object?> map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    return const {};
  }

  /// Returns [value] as a list, or an empty list.
  static List<Object?> list(Object? value) {
    if (value is List) return value;
    return const [];
  }

  /// Splits [items] into chunks of at most [size].
  static Iterable<List<T>> batches<T>(List<T> items, int size) sync* {
    for (var start = 0; start < items.length; start += size) {
      final end = start + size < items.length ? start + size : items.length;
      yield items.sublist(start, end);
    }
  }
}
