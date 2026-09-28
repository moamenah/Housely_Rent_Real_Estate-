import '../models/my_booking.dart';

/// Stays shown on the My Booking screen.
abstract interface class MyBookingRepository {
  /// The demo account's bookings across all three segments.
  Future<List<MyBooking>> getBookings();
}
