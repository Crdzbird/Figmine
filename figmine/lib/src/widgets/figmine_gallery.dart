import 'package:figmine/src/tokens/figmine_token_entry.dart';
import 'package:figmine/src/widgets/figmine_token_tile.dart';
import 'package:flutter/widgets.dart';

/// A scrollable page of design tokens: every entry of [catalog], under
/// the name of its collection, with a preview of its value.
///
/// Pass the generated `appTokenCatalog`. It only needs the widgets layer,
/// so it works in any app and as a Widgetbook use case as is.
final class FigmineGallery extends StatelessWidget {
  /// Creates a gallery of [catalog].
  const factory({
    required List<List<FigmineTokenEntry<Object>>> catalog,
    EdgeInsets padding,
    Key? key,
  }) = FigmineGallery._;

  const new _({
    required this.catalog,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  /// The token catalogues to show, in order.
  final List<List<FigmineTokenEntry<Object>>> catalog;

  /// Space around the list.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final heading = style.copyWith(
      fontSize: (style.fontSize ?? 14) + 4,
      fontWeight: FontWeight.w600,
    );
    final children = <Widget>[];
    String? collection;
    for (final entry in catalog.expand((list) => list)) {
      if (entry.collection != collection) {
        collection = entry.collection;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(collection, style: heading),
          ),
        );
      }
      children.add(FigmineTokenTile(entry: entry));
    }
    return ListView(padding: padding, children: children);
  }
}
