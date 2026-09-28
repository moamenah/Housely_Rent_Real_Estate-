import '../models/my_booking.dart';

/// Data access for the My Booking list.
abstract interface class MyBookingDataSource {
  /// Every booking of the demo account, across the three segments.
  Future<List<MyBooking>> fetchBookings();
}
