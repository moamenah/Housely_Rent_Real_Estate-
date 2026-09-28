import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/my_booking.dart';

/// State of the My Booking ViewModel.
class MyBookingsState extends Equatable {
  const MyBookingsState({
    this.status = RequestStatus.initial,
    this.bookings = const [],
    this.selected = BookingStatus.upcoming,
    this.failure,
  });

  /// Lifecycle of the list load.
  final RequestStatus status;

  /// Every booking, across segments; filtered by [selected] for display.
  final List<MyBooking> bookings;

  /// Which segment pill is active.
  final BookingStatus selected;

  /// Only set for failures (transport problems render the retry screen).
  final Failure? failure;

  bool get isLoading => status == RequestStatus.loading;

  bool get isLoaded => status == RequestStatus.success;

  bool get hasFailed => status == RequestStatus.failure;

  /// Bookings of the active segment.
  List<MyBooking> get visible =>
      bookings.where((booking) => booking.status == selected).toList();

  /// The design's "You have no …" state: the active segment has nothing
  /// to show.
  bool get isEmpty => visible.isEmpty;

  MyBookingsState copyWith({
    RequestStatus? status,
    List<MyBooking>? bookings,
    BookingStatus? selected,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      selected: selected ?? this.selected,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, bookings, selected, failure];
}
