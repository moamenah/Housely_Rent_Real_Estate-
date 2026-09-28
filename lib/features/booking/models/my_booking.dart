import 'package:equatable/equatable.dart';

/// The three segments of the My Booking screen (mockup order).
enum BookingStatus { upcoming, completed, cancelled }

/// Badge colour family — the mockup paints each stay's pill red or green.
enum BookingBadgeTone { danger, success }

/// One row of the My Booking list: a snapshot of the stay (title, address,
/// dates, photo) plus the segment it belongs to and the badge it shows.
class MyBooking extends Equatable {
  const MyBooking({
    required this.id,
    required this.title,
    required this.address,
    required this.dates,
    required this.imageUrl,
    required this.status,
    required this.badge,
    required this.badgeTone,
  });

  /// Segment-local identifier.
  final String id;

  /// Property name on the card ("Batavia Apartments").
  final String title;

  /// Address line, ellipsised on the card.
  final String address;

  /// Stay window as the design prints it ("12 Aug - 12 Sep").
  final String dates;

  /// Property thumbnail (the design's card image is ~88 × 67dp).
  final String imageUrl;

  /// Segment this booking appears under.
  final BookingStatus status;

  /// Badge copy: "Waiting payment", "Checkin", "Completed", "Cancelled".
  final String badge;

  /// Red/green family of [badge].
  final BookingBadgeTone badgeTone;

  @override
  List<Object?> get props =>
      [id, title, address, dates, imageUrl, status, badge, badgeTone];
}
