import 'package:equatable/equatable.dart';

/// How a [NotificationItem]'s leading slot is drawn.
enum NotificationIconKind {
  /// Pale-purple circle with the outline bell + unread dot.
  bell,

  /// Pale-purple circle with the outline person (no dot).
  person,

  /// Round member photo ([NotificationItem.avatarAsset]).
  avatar,
}

/// One run of text inside a notification's rich message — the mockup mixes a
/// gray sentence with a bold dark highlight, so segments carry their weight.
class NotificationSegment extends Equatable {
  const NotificationSegment(this.text, {this.bold = false});

  /// Verbatim text; segments carry their own spaces so they concatenate to
  /// exactly what the design shows.
  final String text;

  /// `true` renders [text] in bold gray900, `false` in the gray body color.
  final bool bold;

  @override
  List<Object?> get props => [text, bold];
}

/// One inbox row: a leading glyph/photo plus a segmented rich message.
class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.segments,
    this.avatarAsset,
    this.unread = false,
  });

  /// Stable identity (mockup order, one row each).
  final String id;

  /// Which leading slot this row uses.
  final NotificationIconKind kind;

  /// Message runs, rendered in order as one wrapped rich text.
  final List<NotificationSegment> segments;

  /// Photo path — only set when [kind] is [NotificationIconKind.avatar].
  final String? avatarAsset;

  /// Draws the red unread dot (the design only dots the bell rows).
  final bool unread;

  /// The plain message, handy for tests and accessibility labels.
  String get message => segments.map((segment) => segment.text).join();

  @override
  List<Object?> get props => [id, kind, segments, avatarAsset, unread];
}

/// One day-group of the inbox ("Today", "Yesterday").
class NotificationSection extends Equatable {
  const NotificationSection({required this.title, required this.items});

  /// Group heading rendered above the rows.
  final String title;

  /// Rows of the group, in mockup order.
  final List<NotificationItem> items;

  @override
  List<Object?> get props => [title, items];
}
