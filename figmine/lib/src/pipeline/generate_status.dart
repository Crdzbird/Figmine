/// What a generate run did.
enum GenerateStatus {
  /// The Figma version matches the lock, nothing was fetched.
  upToDate,

  /// Figma changed, but no token did. Nothing was written.
  unchanged,

  /// Tokens changed and the files were rewritten.
  updated,
}
