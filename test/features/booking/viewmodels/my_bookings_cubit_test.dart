import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/booking/models/my_booking.dart';
import 'package:housely/features/booking/repositories/my_booking_repository.dart';
import 'package:housely/features/booking/viewmodels/my_bookings_cubit.dart';

/// Behavioural fake: returns [bookings] unless [failLoad] is armed.
class _FakeMyBookingRepository implements MyBookingRepository {
  _FakeMyBookingRepository({this.bookings = const []});

  List<MyBooking> bookings;
  bool failLoad = false;
  int calls = 0;

  @override
  Future<List<MyBooking>> getBookings() async {
    calls++;
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return bookings;
  }
}

const MyBooking _bataviaUpcoming = MyBooking(
  id: 'b1',
  title: 'Batavia Apartments',
  address: 'Benhil, Jl. Bendungan Hilir Karet Tengah',
  dates: '12 Aug - 12 Sep',
  imageUrl: 'assets/images/gallery8.png',
  status: BookingStatus.upcoming,
  badge: 'Waiting payment',
  badgeTone: BookingBadgeTone.danger,
);

const MyBooking _takateaCompleted = MyBooking(
  id: 'b3',
  title: 'Takatea Homestay',
  address: 'Jl. Tentara Pelajar No.47, RW.001',
  dates: '08 Aug - 12 Aug',
  imageUrl: 'assets/images/gallery6.png',
  status: BookingStatus.completed,
  badge: 'Completed',
  badgeTone: BookingBadgeTone.success,
);

const MyBooking _tropisCancelled = MyBooking(
  id: 'b4',
  title: 'Tropis Homestay',
  address: 'Jl. Kaliurang No.8, Caturtunggal, Depok',
  dates: '08 Aug - 12 Aug',
  imageUrl: 'assets/images/gallery3.png',
  status: BookingStatus.cancelled,
  badge: 'Cancelled',
  badgeTone: BookingBadgeTone.danger,
);

void main() {
  late _FakeMyBookingRepository repository;

  MyBookingsCubit buildCubit() =>
      MyBookingsCubit(myBookingRepository: repository);

  setUp(() {
    repository = _FakeMyBookingRepository(bookings: const [
      _bataviaUpcoming,
      _takateaCompleted,
      _tropisCancelled,
    ]);
  });

  test('starts on Upcoming, before the first load', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.selected, BookingStatus.upcoming);
    expect(cubit.state.bookings, isEmpty);
    expect(cubit.state.visible, isEmpty);
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.failure, isNull);
  });

  test('load fills the list and shows only the Upcoming segment', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final future = cubit.load();
    expect(cubit.state.isLoading, isTrue);
    await future;

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.bookings, hasLength(3));
    expect(cubit.state.visible, hasLength(1));
    expect(cubit.state.visible.single.title, 'Batavia Apartments');
    expect(cubit.state.isEmpty, isFalse);
    expect(cubit.state.failure, isNull);
  });

  test('selecting a segment filters the loaded list client-side',
      () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();
    expect(repository.calls, 1);

    cubit.select(BookingStatus.completed);
    expect(cubit.state.selected, BookingStatus.completed);
    expect(cubit.state.visible.single.badge, 'Completed');

    cubit.select(BookingStatus.cancelled);
    expect(cubit.state.visible.single.title, 'Tropis Homestay');
    expect(cubit.state.visible.single.badgeTone, BookingBadgeTone.danger);

    // A segment re-select is a no-op (no extra emission).
    cubit.select(BookingStatus.cancelled);
    expect(repository.calls, 1);

    // Back to a segment with nothing to show is the empty state.
    cubit.select(BookingStatus.upcoming);
    expect(cubit.state.visible, hasLength(1));
    expect(cubit.state.isEmpty, isFalse);
  });

  test('an empty account renders the empty state on every segment',
      () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.bookings = [];
    await cubit.load();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.isEmpty, isTrue);

    cubit.select(BookingStatus.cancelled);
    expect(cubit.state.isEmpty, isTrue);
  });

  test('a failing load maps the exception to a Failure', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.failLoad = true;
    await cubit.load();

    expect(cubit.state.hasFailed, isTrue);
    expect(cubit.state.failure, isA<Failure>());
    expect(
      cubit.state.failure?.message,
      'No internet connection. Check your network and try again.',
    );
    expect(cubit.state.isLoaded, isFalse);
  });

  test('retry clears the failure and loads for real', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    repository.failLoad = true;
    await cubit.load();
    expect(cubit.state.hasFailed, isTrue);

    repository.failLoad = false;
    await cubit.load();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.failure, isNull);
    expect(cubit.state.bookings, hasLength(3));
    expect(repository.calls, 2);
  });
}
