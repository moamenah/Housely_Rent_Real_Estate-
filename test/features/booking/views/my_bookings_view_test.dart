import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/constants/app_assets.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/booking/datasources/mock_my_booking_data_source.dart';
import 'package:housely/features/booking/models/my_booking.dart';
import 'package:housely/features/booking/repositories/my_booking_repository.dart';
import 'package:housely/features/booking/views/my_bookings_view.dart';

/// Behavioural fake over the design's own fixture: returns [bookings] unless
/// [failLoad] is armed, or holds the first load open while [gate] is set
/// (that's how the skeleton gets asserted).
class _FakeMyBookingRepository implements MyBookingRepository {
  List<MyBooking> bookings = const [];
  bool failLoad = false;
  Completer<List<MyBooking>>? gate;

  @override
  Future<List<MyBooking>> getBookings() {
    final pending = gate;
    if (pending != null) {
      return pending.future;
    }
    return Future(() async {
      await Future<void>.delayed(Duration.zero);
      if (failLoad) {
        throw const NetworkException();
      }
      return bookings;
    });
  }
}

void main() {
  late GoRouter router;
  late _FakeMyBookingRepository repository;
  late List<MyBooking> fixture;

  void setUpRouter() {
    repository = _FakeMyBookingRepository();
    router = GoRouter(
      initialLocation: RoutePaths.bookings,
      routes: [
        GoRoute(
          path: RoutePaths.bookings,
          builder: (context, state) =>
              MyBookingsView(myBookingRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) =>
              const Scaffold(body: Text('HOME_STUB')),
        ),
      ],
    );
  }

  setUpAll(() async {
    // The mockup copy itself, straight from the design's fixture source.
    fixture = await MockMyBookingDataSource(
      latency: Duration.zero,
    ).fetchBookings();
  });

  setUp(setUpRouter);
  tearDown(() => router.dispose);

  Future<void> pumpBookings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('holds a static skeleton until the stays arrive',
      (tester) async {
    repository
      ..bookings = fixture
      ..gate = Completer<List<MyBooking>>();
    await pumpBookings(tester);

    // Loading is a static placeholder — never an indeterminate spinner.
    expect(find.text('Batavia Apartments'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Upcoming'), findsOneWidget); // segments stay visible
    expect(find.text('You have no upcoming booking'), findsNothing);

    repository.gate!.complete(fixture);
    repository.gate = null;
    await tester.pumpAndSettle();

    expect(find.text('Batavia Apartments'), findsOneWidget);
  });

  testWidgets('the Upcoming segment renders its cards and the chrome',
      (tester) async {
    repository.bookings = fixture;
    await pumpBookings(tester);

    expect(find.text('My Booking'), findsOneWidget);
    expect(find.byKey(const Key('my_bookings_back_button')), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);

    // Both upcoming stays with their badges.
    expect(find.text('Batavia Apartments'), findsOneWidget);
    expect(find.text('Waiting payment'), findsOneWidget);
    expect(find.text('Takatea Homestay'), findsOneWidget);
    expect(find.text('Checkin'), findsOneWidget);
    expect(find.text('12 Aug - 12 Sep'), findsOneWidget);

    // Other segments' cards and the checkout stay off-screen.
    expect(find.text('Tropis Homestay'), findsNothing);
    expect(find.text('Write review'), findsNothing);
    expect(find.text('Price Details'), findsNothing);
  });

  testWidgets('tapping Completed swaps in its card and action rows',
      (tester) async {
    repository.bookings = fixture;
    await pumpBookings(tester);

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Takatea Homestay'), findsOneWidget);
    expect(find.text('Completed'), findsNWidgets(2)); // pill + badge
    expect(find.text('Write review'), findsOneWidget);
    expect(find.text('Call Agent'), findsOneWidget);
    expect(find.text('Batavia Apartments'), findsNothing);
  });

  testWidgets('tapping Cancelled shows the cancelled stay and the call row',
      (tester) async {
    repository.bookings = fixture;
    await pumpBookings(tester);

    await tester.tap(find.text('Cancelled'));
    await tester.pumpAndSettle();

    expect(find.text('Tropis Homestay'), findsOneWidget);
    expect(find.text('Cancelled'), findsNWidgets(2)); // pill + badge
    expect(find.text('Call Agent'), findsOneWidget);
    expect(find.text('Write review'), findsNothing);
    expect(find.text('Batavia Apartments'), findsNothing);
  });

  testWidgets('the action rows answer with an honest stub snackbar',
      (tester) async {
    repository.bookings = fixture;
    await pumpBookings(tester);

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write review'));
    await tester.pumpAndSettle();

    expect(
      find.text("Reviews aren't available in this build yet."),
      findsOneWidget,
    );
  });

  testWidgets('an empty account renders the Opps!! state and its copy',
      (tester) async {
    repository.bookings = [];
    await pumpBookings(tester);

    expect(find.text('Opps!!'), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.bookingOops)), findsOneWidget);
    expect(find.text('You have no upcoming booking'), findsOneWidget);
    expect(
      find.text(
        'are you looking fo a completed or cancelled booking ?',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Batavia Apartments'), findsNothing);
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository
      ..bookings = fixture
      ..failLoad = true;
    await pumpBookings(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.text('Batavia Apartments'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Batavia Apartments'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });

  testWidgets('the back arrow returns to the entry point', (tester) async {
    repository.bookings = fixture;
    await pumpBookings(tester);

    await tester.tap(find.byKey(const Key('my_bookings_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('HOME_STUB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
