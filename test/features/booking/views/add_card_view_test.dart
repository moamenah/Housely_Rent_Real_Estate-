import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
    description: 'Serviced apartments in Benhil.',
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

class _FakeBookingRepository implements BookingRepository {
  @override
  Future<void> confirmBooking({
    required String propertyId,
    required DateTime start,
    required DateTime end,
  }) async {}
}

void main() {
  late BookingCubit bookingCubit;

  setUp(() {
    bookingCubit = BookingCubit(bookingRepository: _FakeBookingRepository());
    addTearDown(bookingCubit.close);
  });

  Future<void> pumpCheckout(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/booking',
      routes: [
        GoRoute(
          path: '/booking',
          builder: (_, __) => const BookingView(),
        ),
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

  Future<void> openAddCard(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('booking_add_credit')));
    await tester.pumpAndSettle();
    expect(find.text('Add Card'), findsOneWidget);
  }

  testWidgets('renders the sample card and validates before saving',
      (tester) async {
    await pumpCheckout(tester);
    await openAddCard(tester);

    // The mockup's filled sample.
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Brooklyn Simmons'), findsOneWidget);
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('1234 5678 9101 1121'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('06/21'), findsOneWidget);
    expect(find.text('Cvv'), findsOneWidget);
    expect(find.text('3134'), findsOneWidget);
    expect(find.text('Add card'), findsOneWidget);

    // A short number is rejected under its own message.
    await tester.enterText(
      find.byKey(const Key('add_card_number_field')),
      '12345',
    );
    await tester.tap(find.byKey(const Key('add_card_submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter the full 16-digit card number.'),
      findsOneWidget,
    );
    expect(find.text('Add Card'), findsOneWidget);

    // Fixing the field lets the form through; the card lands on the
    // checkout and pins the Confirm bar.
    await tester.enterText(
      find.byKey(const Key('add_card_number_field')),
      '4111111111111111',
    );
    await tester.tap(find.byKey(const Key('add_card_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Add Card'), findsNothing);
    expect(find.text('...........1111'), findsOneWidget);
    expect(find.text('Confirm and Pay'), findsOneWidget);
    expect(bookingCubit.state.card!.digits, '4111111111111111');
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing the attached card keeps what it knows, re-asks the CVV',
      (tester) async {
    bookingCubit.attachCard(
      const PaymentCard(
        cardholder: 'Ada Lovelace',
        number: '4111 1111 1111 1111',
        expiry: '09/27',
      ),
    );
    await pumpCheckout(tester);

    await tester.tap(find.byKey(const Key('booking_edit_card')));
    await tester.pumpAndSettle();
    expect(find.text('Add Card'), findsOneWidget);

    final fields = {
      for (final key in [
        'add_card_name_field',
        'add_card_number_field',
        'add_card_expiry_field',
        'add_card_cvv_field',
      ])
        key: tester.widget<TextField>(find.byKey(Key(key))).controller!.text,
    };
    expect(fields['add_card_name_field'], 'Ada Lovelace');
    expect(fields['add_card_number_field'], '4111 1111 1111 1111');
    expect(fields['add_card_expiry_field'], '09/27');
    expect(fields['add_card_cvv_field'], isEmpty); // never stored

    // Without a CVV the form refuses to save.
    await tester.tap(find.byKey(const Key('add_card_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Enter the 3-4 digit CVV.'), findsOneWidget);
    expect(find.text('Add Card'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('add_card_cvv_field')), '987');
    await tester.tap(find.byKey(const Key('add_card_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Add Card'), findsNothing);
    expect(find.text('...........1111'), findsOneWidget);
    expect(bookingCubit.state.card!.cardholder, 'Ada Lovelace');
    expect(tester.takeException(), isNull);
  });
}
