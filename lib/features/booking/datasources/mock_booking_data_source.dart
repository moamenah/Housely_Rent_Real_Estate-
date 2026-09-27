import 'booking_data_source.dart';

/// Offline payment stub.
///
/// Always approves after a short latency — long enough for the checkout
/// button's disabled state to be real, short enough to stay out of the way.
class MockBookingDataSource implements BookingDataSource {
  MockBookingDataSource({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  }) async {
    await Future<void>.delayed(latency);
  }
}
