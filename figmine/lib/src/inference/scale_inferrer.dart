/// Turns usage counts into a scale of commonly used values.
abstract final class ScaleInferrer {
  /// Values used at least twice and in at least [minShare] of all uses,
  /// keeping the [max] most common, in ascending order.
  static List<int> scale(
    Map<int, int> counts, {
    double minShare = 0.02,
    int max = 12,
  }) {
    final total = counts.values.fold(0, (sum, n) => sum + n);
    if (total == 0) return const [];
    final common =
        counts.entries
            .where((e) => e.value >= 2 && e.value / total >= minShare)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in common.take(max)) e.key]..sort();
  }
}
