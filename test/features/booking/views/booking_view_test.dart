import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/booking/models/payment_card.dart';
import 'package:housely/features/booking/repositories/booking_repository.dart';
import 'package:housely/features/booking/viewmodels/booking_cubit.dart';
import 'package:housely/features/booking/views/add_card_view.dart';
import 'package:housely/features/booking/views/booking_view.dart';
import 'package:housely/features/properties/models/property.dart';
import 'package:housely/features/properties/repositories/property_repository.dart';
import 'package:housely/features/properties/viewmodels/properties_cubit.dart';

/// Behavioural fake: the Batavia fixture from the shared corpus.
class _FakePropertyRepository implements PropertyRepository {
  static final Property _property = Property(
    id: '8',
    title: 'Batavia Apartments',
    description:
        'Serviced apartments in Benhil with a shared gym and 24h security, '
        'ten minutes from the business district.',
    price: 120,
    pricePeriod: PricePeriod.night,
    location: 'Benhil, Jl. Bendungan Hilir Karet Tengah',
    bedrooms: 2,
    bathrooms: 1,
    areaSqm: 74,
    imageUrl: 'assets/images/gallery_8.png',
    rating: 4.5,
    reviewsCount: 87,
  );

  @override
  Future<List<Property>> getProperties() async {
    await Future<void>.delayed(Duration.zero);
    return [_property];
  }

  @override
  Future<Property> getPropertyById(String id) async => _property;
}

/// Behavioural fake: approves confirms unless [failConfirm] is armed.
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
  late _FakeBookingRepository bookingRepository;
  late BookingCubit bookingCubit;

  setUp(() {
    bookingRepository = _FakeBookingRepository();
    bookingCubit = BookingCubit(bookingRepository: bookingRepository);
    addTearDown(bookingCubit.close);
  });

  Future<void> pumpBooking(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/booking',
      routes: [
        GoRoute(path: '/booking', builder: (_, __) => const BookingView()),
        GoRoute(
          path: '/booking/add-card',
          builder: (_, __) => const AddCardView(),
        ),
        GoRoute(
          path: '/explore',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Featured'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BookingCubit>.value(value: bookingCubit),
          BlocProvider<PropertiesCubit>(
            create: (_) => PropertiesCubit(
              repository: _FakePropertyRepository(),
            )..fetchProperties(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every section of the design', (tester) async {
    await pumpBooking(tester);

    // Chrome.
    expect(find.text('Booking'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Property card â€” corpus data (120/night, rating 4.5).
    expect(find.text('Batavia Apartments'), findsOneWidget);
    expect(
      find.text('Benhil, Jl. Bendungan Hilir Karet Tengah'),
      findsOneWidget,
    );
    expect(find.text(r'$120/night', findRichText: true), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);

    // Period.
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('12 Aug - 12 Sep'), findsOneWidget);
    expect(
      find.text(
        'Make sure to check your date before making any sort of payments',
      ),
      findsOneWidget,
    );

    // Payments (no method attached yet).
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Credit or Debit card'), findsOneWidget);
    expect(find.text('Paypal'), findsOneWidget);
    expect(find.text('Enter a Voucher'), findsOneWidget);

    // Price breakdown: 120 + 10 tax.
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.text('Period time'), findsOneWidget);
    expect(find.text('1 Month'), findsOneWidget);
    expect(find.text('Monthly payment'), findsOneWidget);
    expect(find.text(r'$120.00'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text(r'$10.00'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text(r'$130.00'), findsOneWidget);

    // No payment method â†’ no Confirm bar (first mockup).
    expect(find.text('Confirm and Pay'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the date sheet re-picks the period', (tester) async {
    await pumpBooking(tester);

    await tester.tap(find.byKey(const Key('booking_date_row')));
    await tester.pumpAndSettle();

    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('August 2022'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Set time on your calendar'), findsOneWidget);
    for (final weekday in [
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
    ]) {
      expect(find.text(weekday), findsOneWidget);
    }

    // Page the month with the mockup's outlined arrows (the sheet's arrow
    // sits above the period row's chevron in the overlay).
    await tester.tap(find.byIcon(Icons.chevron_right).last);
    await tester.pumpAndSettle();
    expect(find.text('September 2022'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left).last);
    await tester.pumpAndSettle();
    expect(find.text('August 2022'), findsOneWidget);

    // First tap restarts the range, second completes it.
    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('25'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Select Date'), findsNothing);
    expect(find.text('20 Aug - 25 Aug'), findsOneWidget);
    expect(find.text('5 Days'), findsOneWidget);
  });

  testWidgets('paypal and voucher report the honest stubs', (tester) async {
    await pumpBooking(tester);

    await tester.tap(find.byKey(const Key('booking_add_paypal')));
    await tester.pumpAndSettle();
    expect(
      find.text("Paypal checkout isn't available in this build yet."),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('booking_voucher')));
    await tester.pumpAndSettle();
    expect(
      find.text("Vouchers aren't available in this build yet."),
      findsOneWidget,
    );
  });

  testWidgets('an attached card confirms into the success sheet',
      (tester) async {
    await pumpBooking(tester);

    bookingCubit.attachCard(
      const PaymentCard(
        cardholder: 'Brooklyn Simmons',
        number: '1234 5678 9101 1121',
        expiry: '06/21',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('...........1121'), findsOneWidget);
    expect(find.text('Confirm and Pay'), findsOneWidget);

    await tester.tap(find.byKey(const Key('booking_confirm')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Yey, your booking success'), findsOneWidget);
    expect(
      find.text(
        'You have successfully booked a property, enjoy your property',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Explore more'));
    await tester.pumpAndSettle();
    expect(find.text('Featured'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed confirm announces itself', (tester) async {
    bookingRepository.failConfirm = true;
    await pumpBooking(tester);

    bookingCubit.attachCard(
      const PaymentCard(
        cardholder: 'Brooklyn Simmons',
        number: '1234 5678 9101 1121',
        expiry: '06/21',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('booking_confirm')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.text('Yey, your booking success'), findsNothing);
    // The bar is usable again for a retry.
    expect(
      tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm and Pay'),
      ).onPressed,
      isNotNull,
    );
  });
}
