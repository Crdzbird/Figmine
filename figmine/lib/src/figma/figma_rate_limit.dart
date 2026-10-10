/// Thrown when Figma rate limits a request for longer than figmine waits.
final class FigmaRateLimit implements Exception {
  /// Creates the error from the headers of a 429 response.
  const factory({
    required String path,
    required int retryAfter,
    String? type,
    String? plan,
    String? upgradeLink,
  }) = FigmaRateLimit._;

  const new _({
    required this.path,
    required this.retryAfter,
    this.type,
    this.plan,
    this.upgradeLink,
  });

  /// Reads the error from the [headers] of a 429 response to [path].
  factory from(String path, Map<String, String> headers) => FigmaRateLimit(
    path: path,
    retryAfter: int.tryParse(headers['retry-after'] ?? '') ?? 0,
    type: headers['x-figma-rate-limit-type'],
    plan: headers['x-figma-plan-tier'],
    upgradeLink: headers['x-figma-upgrade-link'],
  );

  /// The request that was limited.
  final String path;

  /// Seconds Figma asks to wait.
  final int retryAfter;

  /// `low` for View and Collab seats, `high` for Dev and Full seats.
  final String? type;

  /// Plan of the file, such as `org`.
  final String? plan;

  /// Where Figma offers a seat with higher limits.
  final String? upgradeLink;

  /// The wait in days, hours and minutes.
  String get wait {
    final d = Duration(seconds: retryAfter);
    final parts = [
      if (d.inDays > 0) '${d.inDays}d',
      if (d.inHours % 24 > 0) '${d.inHours % 24}h',
      '${d.inMinutes % 60}m',
    ];
    return parts.join(' ');
  }

  @override
  String toString() {
    final lines = ['Figma rate limited $path for $wait.'];
    if (type == 'low') {
      lines
        ..add(
          'This token has a View or Collab seat on this ${plan ?? ''} file, '
          'which allows about 20 file and node reads a month. figmine '
          'caches reads by file version, so reruns of the same version are '
          'free.',
        )
        ..add(
          'To sync now: use a token from a Dev or Full seat, or export the '
          'tokens with the figmine exporter plugin and list the JSON in '
          'tokens.files.',
        );
    }
    if (upgradeLink != null) lines.add('Seats: $upgradeLink');
    return lines.join('\n');
  }
}
