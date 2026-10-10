/// A top-level frame with the page it sits on.
typedef ScreenFrame = ({String page, Map<String, Object?> node});

/// The designed screens of a file, with the style and component metadata
/// Figma returns alongside them.
final class ScreenSet {
  /// Creates a screen set.
  const factory({
    required List<ScreenFrame> frames,
    Map<String, Map<String, Object?>> styles,
    Map<String, Map<String, Object?>> components,
    Map<String, Map<String, Object?>> componentSets,
  }) = ScreenSet._;

  const new _({
    required this.frames,
    this.styles = const {},
    this.components = const {},
    this.componentSets = const {},
  });

  /// The frames, in page order.
  final List<ScreenFrame> frames;

  /// Styles used by the frames, keyed by style id.
  final Map<String, Map<String, Object?>> styles;

  /// Components used by the frames, keyed by node id.
  final Map<String, Map<String, Object?>> components;

  /// Component sets used by the frames, keyed by node id.
  final Map<String, Map<String, Object?>> componentSets;
}
