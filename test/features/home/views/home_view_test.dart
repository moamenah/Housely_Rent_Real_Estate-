import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/constants/app_colors.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/favorites/viewmodels/favorites_cubit.dart';
import 'package:housely/features/home/models/home_feed.dart';
import 'package:housely/features/home/models/top_location.dart';
import 'package:housely/features/home/repositories/home_repository.dart';
import 'package:housely/features/home/views/home_view.dart';
import 'package:housely/features/home/views/popular_view.dart';
import 'package:housely/features/home/views/widgets/heart_button.dart';
import 'package:housely/features/home/views/widgets/top_location_chip.dart';
import 'package:housely/features/properties/models/property.dart';

/// Behavioural fake: mirrors the real feed's section membership unless
/// [failLoad] is armed.
class _FakeHomeRepository implements HomeRepository {
  bool failLoad = false;

  @override
  Future<HomeFeed> getFeed() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return HomeFeed(
      recommended: [
        _property('1', 'Ayana Homestay', 310),
        _property('2', 'Bali Komang Guest', 240),
      ],
      nearby: [
        _property('3', 'Maharani Villa Yogyakarta', 320),
        _property('4', 'Apartement landing Seturan', 180),
        _property('6', 'Prawirotaman Loft', 210),
        _property('7', 'Sindu Praya Loft', 195),
      ],
      popular: [
        _property('5', 'Takatea Homestay', 120, period: PricePeriod.night),
        _property('3', 'Maharani Villa Yogyakarta', 320),
        _property('2', 'Bali Komang Guest', 240),
        _property('8', 'Batavia Apartments', 120, period: PricePeriod.night),
        _property('9', 'Manhattan Hotel', 230, period: PricePeriod.night),
      ],
      topLocations: const [
        TopLocation(name: 'Malang', imageUrl: 'assets/images/gallery_7.png'),
        TopLocation(name: 'Bali', imageUrl: 'assets/images/gallery_9.png'),
        TopLocation(name: 'Yogyakarta', imageUrl: 'assets/images/gallery_8.png'),
        TopLocation(name: 'Lombok', imageUrl: 'assets/images/gallery_1.png'),
      ],
    );
  }
}

Property _property(
  String id,
  String title,
  double price, {
  PricePeriod period = PricePeriod.month,
}) =>
    Property(
      id: id,
      title: title,
      description: 'Cozy stay',
      price: price,
      pricePeriod: period,
      location: 'Imogiri, Yogyakarta',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 90,
      imageUrl: 'assets/images/gallery_1.png',
      rating: 4.8,
      reviewsCount: 126,
    );

void main() {
  late GoRouter router;
  late _FakeHomeRepository repository;
  late FavoritesCubit favorites;

  void setUpRouter() {
    repository = _FakeHomeRepository();
    favorites = FavoritesCubit();
    router = GoRouter(
      initialLocation: RoutePaths.home,
      routes: [
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) => HomeView(homeRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.explore,
          builder: (context, state) =>
              const Scaffold(body: Text('EXPLORE_STUB')),
        ),
        GoRoute(
          path: RoutePaths.popular,
          builder: (context, state) =>
              PopularView(homeRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.propertyDetails,
          builder: (context, state) =>
              const Scaffold(body: Text('PROPERTY_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() {
    router.dispose();
    favorites.close();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>.value(
        value: favorites,
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.light),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the mockup chrome and every feed section',
      (tester) async {
    await pumpHome(tester);

    // Chrome sits above the fold.
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Yogyakarta, Ind'), findsOneWidget);
    expect(find.text('Search Property'), findsOneWidget);

    // Nudge the feed up so every rail's items are laid out, then assert the
    // whole page (built-but-scroll-away content is found with
    // `skipOffstage: false`).
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
    );
    await tester.drag(verticalScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(find.text('Recommended', skipOffstage: false), findsOneWidget);
    expect(find.text('Nearby', skipOffstage: false), findsOneWidget);
    expect(find.text('Top Locations', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Popular for you', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('See all', skipOffstage: false), findsNWidgets(4));

    // The featured rail joined against the corpus (ids 1 and 2).
    expect(find.text('Ayana Homestay', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Bali Komang Guest', skipOffstage: false),
      findsNWidgets(2),
    );
    // Price pill of the first card: amount + billing suffix.
    expect(find.text('\$310', skipOffstage: false), findsOneWidget);
    // Two featured cards + three Popular rows carry a favourite heart.
    expect(
      find.byIcon(Icons.favorite_border, skipOffstage: false),
      findsNWidgets(5),
    );

    // Destination chips, Malang → Lombok.
    for (final city in ['Malang', 'Bali', 'Yogyakarta', 'Lombok']) {
      expect(find.text(city, skipOffstage: false), findsOneWidget);
    }
  });

  testWidgets('search hops to Explore', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Search Property'));
    await tester.pumpAndSettle();

    expect(find.text('EXPLORE_STUB'), findsOneWidget);
  });

  testWidgets('the Recommended See all hops to Explore', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();

    expect(find.text('EXPLORE_STUB'), findsOneWidget);
  });

  testWidgets('the Popular See all pushes the full popular list',
      (tester) async {
    await pumpHome(tester);

    // Bring every section header on stage — they are stacked in order.
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
    );
    await tester.drag(verticalScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('See all', skipOffstage: false).at(3),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // Pushed inside the Home branch: the AppBar back arrow returns to feed.
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Takatea Homestay'), findsOneWidget);
    expect(find.text('Manhattan Hotel'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(
      find.text('Popular for you', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('tapping a featured card opens its details', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Ayana Homestay'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('PROPERTY_STUB'), findsOneWidget);
  });

  testWidgets('destination chips move the highlighted selection',
      (tester) async {
    await pumpHome(tester);

    // Bring the Top Locations rail on stage.
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
    );
    await tester.drag(verticalScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();

    Color chipColor(int index) {
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(TopLocationChip).at(index),
              matching: find.byType(Material),
            )
            .first,
      );
      return material.color!;
    }

    // Bali is preselected exactly like the mockup.
    expect(chipColor(1), AppColors.primary);
    expect(chipColor(0), AppColors.white);

    await tester.tap(find.text('Malang'));
    await tester.pumpAndSettle();

    expect(chipColor(0), AppColors.primary);
    expect(chipColor(1), AppColors.white);
  });

  testWidgets('the featured heart toggles the session favorites',
      (tester) async {
    await pumpHome(tester);
    expect(favorites.state.isFavorite('1'), isFalse);

    await tester.tap(find.byType(HeartButton).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(favorites.state.isFavorite('1'), isTrue);
    // Toggling off again returns to the outline state.
    await tester.tap(find.byType(HeartButton).first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(favorites.state.isFavorite('1'), isFalse);
  });

  testWidgets('a failed feed announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpHome(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.text('Recommended'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });

  testWidgets('peripheral actions are stubbed with a banner', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();
    expect(
      find.text("Changing your location isn't available in this build yet."),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    expect(
      find.text("Notifications aren't available in this build yet."),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();
    expect(
      find.text("Messages aren't available in this build yet."),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('home_promo_banner')));
    await tester.pumpAndSettle();
    expect(
      find.text("This offer isn't available in this build yet."),
      findsOneWidget,
    );
  });
}
