import '../datasources/my_booking_data_source.dart';
import '../models/my_booking.dart';
import 'my_booking_repository.dart';

/// Delegates the My Booking list to its data source (the mock fixture until
/// a real bookings endpoint exists).
class MyBookingRepositoryImpl implements MyBookingRepository {
  const MyBookingRepositoryImpl({required this.dataSource});

  final MyBookingDataSource dataSource;

  @override
  Future<List<MyBooking>> getBookings() => dataSource.fetchBookings();
}
