import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/booking/models/payment_card.dart';
import 'package:housely/features/booking/repositories/booking_repository.dart';
import 'package:housely/features/booking/viewmodels/booking_cubit.dart';

/// Behavioural fake: approves every confirm unless [failConfirm] is armed.
class _FakeBookingRepository implements BookingRepository {
  bool failConfirm = false;

  @override
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (failConfirm) {
      throw const NetworkException();
    }
  }
}

void main() {
  late _FakeBookingRepository repository;

  BookingCubit buildCubit() => BookingCubit(bookingRepository: repository);

  setUp(() {
    repository = _FakeBookingRepository();
  });

  test('starts on the mockup demo booking', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.propertyId, '8');
    expect(cubit.state.periodLabel, '12 Aug - 12 Sep');
    expect(cubit.state.durationLabel, '1 Month');
    expect(cubit.state.hasCard, isFalse);
    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.failure, isNull);
  });

  test('startBooking swaps the listing, keeps card and period, resets status',
      () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.setPeriod(DateTime(2022, 8, 20), DateTime(2022, 8, 25));
    cubit.attachCard(
      const PaymentCard(
        cardholder: 'Brooklyn Simmons',
        number: '1234 5678 9101 1121',
        expiry: '06/21',
      ),
    );
    await cubit.confirm();
    expect(cubit.state.hasConfirmed, isTrue);

    cubit.startBooking('1');

    expect(cubit.state.propertyId, '1');
    expect(cubit.state.periodLabel, '20 Aug - 25 Aug');
    expect(cubit.state.hasCard, isTrue);
    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.failure, isNull);
  });

  test('setPeriod normalises a reversed range', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.setPeriod(DateTime(2022, 9, 12), DateTime(2022, 8, 12));

    expect(cubit.state.periodStart, DateTime(2022, 8, 12));
    expect(cubit.state.periodEnd, DateTime(2022, 9, 12));
    expect(cubit.state.periodLabel, '12 Aug - 12 Sep');
  });

  test('durationLabel counts whole months, then nights, then a single day',
      () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    // Whole-month anniversary: the mockup's default.
    expect(cubit.state.durationLabel, '1 Month');

    cubit.setPeriod(DateTime(2022, 8, 20), DateTime(2022, 8, 25));
    expect(cubit.state.durationLabel, '5 Days');

    cubit.setPeriod(DateTime(2022, 8, 20), DateTime(2022, 9, 20));
    expect(cubit.state.durationLabel, '1 Month');

    cubit.setPeriod(DateTime(2022, 8, 20), DateTime(2022, 8, 20));
    expect(cubit.state.durationLabel, '1 Day');
  });

  test('confirm resolves to a success state', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.confirm();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.hasConfirmed, isTrue);
    expect(cubit.state.failure, isNull);
  });

  test('a gateway failure becomes a retryable failure state', () async {
    repository.failConfirm = true;
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.confirm();

    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());

    // The view's retry simply confirms again.
    repository.failConfirm = false;
    await cubit.confirm();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.failure, isNull);
  });
}
