import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/app/app.dart';
import 'package:housely/core/di/injection.dart';
import 'package:housely/core/routing/app_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/features/profile/views/widgets/profile_avatar.dart';

/// End-to-end check of the design's five-tab shell, using the real router and
/// the real (mock) data layer.
///
/// Every branch is visited — the fixtures now render local design-kit assets,
/// so nothing in this file touches the network.
void main() {
  setUpAll(() async {
    await configureDependencies();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HouselyApp());
    await tester.pumpAndSettle();
    // Let the splash's minimum display time elapse (its Cubit would otherwise
    // emit after being disposed by the jump below), then enter the shell.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    appRouter.go(RoutePaths.home);
    await tester.pumpAndSettle();
    // The Home feed resolves after its mock data source's latency.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  }

  testWidgets('the bar shows all five tabs and the real Home feed',
      (tester) async {
    await pumpShell(tester);

    // The tab bar: one label each (Home's screen no longer doubles the word).
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('My Booking'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Home chrome sits above the fold.
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Yogyakarta, Ind'), findsOneWidget);
    expect(find.text('Search Property'), findsOneWidget);

    // Nudge the feed up so all four section headers sit on stage (the body
    // runs to 772px above the shell's 72px tab bar).
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
    );
    await tester.drag(verticalScrollable, const Offset(0, -250));
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('Top Locations'), findsOneWidget);
    expect(find.text('Popular for you'), findsOneWidget);
    expect(find.text('See all'), findsNWidgets(4));
    // Featured rail joined against the shared corpus (id 1).
    expect(find.text('Ayana Homestay'), findsWidgets);
    expect(find.text('\$310'), findsOneWidget);
    // Destination chips (home-only strings; the fourth peeks off-screen).
    for (final city in ['Malang', 'Bali', 'Yogyakarta', 'Lombok']) {
      expect(find.text(city, skipOffstage: false), findsOneWidget);
    }
  });

  testWidgets('tapping tabs switches branches across the shell',
      (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('My Booking'));
    await tester.pumpAndSettle();
    // The tab renders the checkout itself — the demo booking from the
    // mockup, without a payment method (so no Confirm bar yet).
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.text('Batavia Apartments'), findsOneWidget);
    expect(find.text('12 Aug - 12 Sep'), findsOneWidget);
    expect(find.text('Confirm and Pay'), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text('Brooklyn Simmons'), findsOneWidget);
    expect(find.text('brooklynsim@gmail.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    // Title + tab label.
    expect(find.text('Profile'), findsNWidgets(2));

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Featured'), findsOneWidget);
    expect(find.text('Ayana Homestay'), findsWidgets);

    // Seeded to the mockup's heart states (ids 1–3 and 9).
    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();
    expect(find.text('Ayana Homestay'), findsOneWidget);
    expect(find.text('Bali Komang Guest'), findsOneWidget);

    // The compact rows all fit; reveal the third seeded favourite anyway.
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
    );
    await tester.drag(verticalScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Maharani Villa Yogyakarta'), findsOneWidget);
    expect(find.text('Manhattan Hotel'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Popular for you', skipOffstage: false), findsOneWidget);
  });

  testWidgets('a favourite card opens details over the shell', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ayana Homestay'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // The details screen renders over the shell and closes again cleanly —
    // no duplicate Hero tags across branches, no missing providers.
    expect(find.text('Property Details'), findsOneWidget);
    expect(find.text('Rent now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rent now runs the checkout through to the success sheet',
      (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayana Homestay'), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rent now'));
    await tester.pumpAndSettle();

    // The checkout opens for the listing being rented (not the tab's demo).
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Ayana Homestay'), findsOneWidget);
    expect(
      find.text(r'$310/month', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Confirm and Pay'), findsNothing);

    // Attach the mockup's sample card through the Add Card form.
    await tester.tap(find.byKey(const Key('booking_add_credit')));
    await tester.pumpAndSettle();
    expect(find.text('Add Card'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add_card_submit')));
    await tester.pumpAndSettle();

    expect(find.text('...........1121'), findsOneWidget);
    expect(find.text('Confirm and Pay'), findsOneWidget);
    // With a payment method attached the design drops the date warning.
    expect(
      find.text(
        'Make sure to check your date before making any sort of payments',
      ),
      findsNothing,
    );

    // Confirm → mock gateway latency → success sheet → Explore more.
    await tester.tap(find.byKey(const Key('booking_confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Yey, your booking success'), findsOneWidget);
    expect(find.text('Explore more'), findsOneWidget);

    await tester.tap(find.text('Explore more'));
    await tester.pumpAndSettle();
    expect(find.text('Featured'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
