import '../datasources/booking_data_source.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl({required BookingDataSource dataSource})
      : _dataSource = dataSource;

  final BookingDataSource _dataSource;

  @override
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  }) {
    // Normalisation lives here (not in the data source): every transport —
    // mock, payment gateway, booking API — receives the same clean payload,
    // so a reversed range can never reach the payment side.
    final reversed = end.isBefore(start);
    return _dataSource.confirmBooking(
      propertyId: propertyId.trim(),
      start: reversed ? end : start,
      end: reversed ? start : end,
    );
  }
}
