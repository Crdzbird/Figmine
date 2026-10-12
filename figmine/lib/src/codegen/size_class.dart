/// Window size classes, as in Material: compact below 600 wide, medium
/// below 840, expanded from there.
enum SizeClass {
  /// Phones.
  compact('mobile|phone|compact|small|xs'),

  /// Tablets and small windows.
  medium('tablet|medium|md'),

  /// Desktops and the web.
  expanded('desktop|web|large|expanded|lg|xl|wide');

  new(this.words);

  /// Words in a mode name that mean this size class.
  final String words;
}
