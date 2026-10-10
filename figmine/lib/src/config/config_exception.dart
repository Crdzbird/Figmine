/// Thrown when `figmine.yaml` is missing or invalid.
final class ConfigException implements Exception {
  /// Creates an exception with a readable [message].
  const factory(String message) = ConfigException._;

  const new _(this.message);

  /// What is wrong with the configuration.
  final String message;

  @override
  String toString() => 'Invalid figmine configuration: $message';
}
