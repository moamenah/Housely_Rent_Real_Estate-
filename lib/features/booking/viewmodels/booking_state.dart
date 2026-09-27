import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/payment_card.dart';

/// State of the checkout ViewModel.
///
/// One session spans both entry points (the My Booking tab and the details
/// screen's "Rent now"): which listing is being booked, the chosen period,
/// the attached card and the confirm request's status.
class BookingState extends Equatable {
  BookingState({
    this.propertyId = defaultPropertyId,
    DateTime? periodStart,
    DateTime? periodEnd,
    this.card,
    this.status = RequestStatus.initial,
    this.failure,
  })  : periodStart = periodStart ?? defaultPeriodStart,
        periodEnd = periodEnd ?? defaultPeriodEnd;

  /// The demo booking from the mockup — Batavia Apartments.
  static const String defaultPropertyId = '8';

  /// "12 Aug - 12 Sep" from both Booking mockups.
  static final DateTime defaultPeriodStart = DateTime(2022, 8, 12);
  static final DateTime defaultPeriodEnd = DateTime(2022, 9, 12);

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Listing being checked out (a corpus id).
  final String propertyId;

  /// Inclusive first night of the stay.
  final DateTime periodStart;

  /// Checkout day of the stay.
  final DateTime periodEnd;

  /// Attached payment method — `null` until the user saves a card.
  final PaymentCard? card;

  /// Status of the confirm request.
  final RequestStatus status;

  /// Populated only when [status] is [RequestStatus.failure].
  final Failure? failure;

  bool get hasCard => card != null;

  bool get isConfirming => status == RequestStatus.loading;

  bool get hasConfirmed => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  /// Mockup's date row: `12 Aug - 12 Sep`.
  String get periodLabel =>
      '${periodStart.day} ${_monthNames[periodStart.month - 1]} - '
      '${periodEnd.day} ${_monthNames[periodEnd.month - 1]}';

  /// Mockup's "Period time" row: whole months when the range covers month
  /// anniversaries (`12 Aug → 12 Sep` = `1 Month`), nights otherwise.
  String get durationLabel {
    final months = _wholeMonths(periodStart, periodEnd);
    if (months > 0) return months == 1 ? '1 Month' : '$months Months';
    final nights = periodEnd.difference(periodStart).inDays;
    return nights <= 0 ? '1 Day' : '$nights Days';
  }

  /// How many whole calendar months fit between [a] and [b] (day-of-month
  /// clamped, so `31 Jan + 1 month` is `28 Feb`, not `3 Mar`).
  static int _wholeMonths(DateTime a, DateTime b) {
    final months = (b.year - a.year) * 12 + (b.month - a.month);
    if (months <= 0) return 0;
    final lastDay = DateTime(b.year, b.month + 1, 0).day;
    final anniversary = DateTime(
      b.year,
      b.month,
      a.day <= lastDay ? a.day : lastDay,
    );
    return anniversary.isAfter(b) ? months - 1 : months;
  }

  BookingState copyWith({
    String? propertyId,
    DateTime? periodStart,
    DateTime? periodEnd,
    PaymentCard? card,
    RequestStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return BookingState(
      propertyId: propertyId ?? this.propertyId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      card: card ?? this.card,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props =>
      [propertyId, periodStart, periodEnd, card, status, failure];
}
