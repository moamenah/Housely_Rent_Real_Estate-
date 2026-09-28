import '../../../core/constants/app_assets.dart';
import '../models/my_booking.dart';
import 'my_booking_data_source.dart';

/// Offline fixture — the design's cards: two upcoming stays (one waiting for
/// payment, one checked in), a completed stay and a cancelled one.
///
/// Latency is simulated so the loading skeleton on the screen is real rather
/// than an instant flip.
class MockMyBookingDataSource implements MyBookingDataSource {
  MockMyBookingDataSource({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  static const String _takateaAddress = 'Jl. Tentara Pelajar No.47, RW.001';

  static const List<MyBooking> _bookings = [
    MyBooking(
      id: 'b1',
      title: 'Batavia Apartments',
      address: 'Benhil, Jl. Bendungan Hilir Karet Tengah',
      dates: '12 Aug - 12 Sep',
      imageUrl: AppAssets.gallery8,
      status: BookingStatus.upcoming,
      badge: 'Waiting payment',
      badgeTone: BookingBadgeTone.danger,
    ),
    MyBooking(
      id: 'b2',
      title: 'Takatea Homestay',
      address: _takateaAddress,
      dates: '08 Aug - 12 Aug',
      imageUrl: AppAssets.gallery6,
      status: BookingStatus.upcoming,
      badge: 'Checkin',
      badgeTone: BookingBadgeTone.success,
    ),
    MyBooking(
      id: 'b3',
      title: 'Takatea Homestay',
      address: _takateaAddress,
      dates: '08 Aug - 12 Aug',
      imageUrl: AppAssets.gallery6,
      status: BookingStatus.completed,
      badge: 'Completed',
      badgeTone: BookingBadgeTone.success,
    ),
    MyBooking(
      id: 'b4',
      title: 'Tropis Homestay',
      address: 'Jl. Kaliurang No.8, Caturtunggal, Depok',
      dates: '08 Aug - 12 Aug',
      imageUrl: AppAssets.gallery3,
      status: BookingStatus.cancelled,
      badge: 'Cancelled',
      badgeTone: BookingBadgeTone.danger,
    ),
  ];

  @override
  Future<List<MyBooking>> fetchBookings() async {
    await Future<void>.delayed(latency);
    return _bookings;
  }
}
