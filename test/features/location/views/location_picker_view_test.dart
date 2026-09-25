import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/location/models/place.dart';
import 'package:housely/features/location/repositories/location_repository.dart';
import 'package:housely/features/location/views/location_picker_view.dart';

/// Behavioural fake: resolves anything unless the test arms [failLoad] /
/// [failSearch], which is how the banner + retry paths get exercised.
class _FakeLocationRepository implements LocationRepository {
  bool failLoad = false;
  bool failSearch = false;

  static const pinned = Place(
    id: 'pinned',
    address: 'Jl. Jend. Sudirman, Gowongan, Kec. Jetis, Kota Yogyakarta',
  );

  @override
  Future<Place> getPinnedPlace() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return pinned;
  }

  @override
  Future<Place> searchPlace({required String query}) async {
    await Future<void>.delayed(Duration.zero);
    if (failSearch) {
      throw const NetworkException();
    }
    return Place(id: 'search', address: '$query, Kota Yogyakarta');
  }
}

void main() {
  const networkMessage =
      'No internet connection. Check your network and try again.';

  late GoRouter router;
  late _FakeLocationRepository repository;

  void setUpRouter() {
    repository = _FakeLocationRepository();
    router = GoRouter(
      initialLocation: RoutePaths.locationPicker,
      routes: [
        GoRoute(
          path: RoutePaths.locationPicker,
          builder: (context, state) =>
              LocationPickerView(locationRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.locationPermission,
          builder: (context, state) =>
              const Scaffold(body: Text('PERMISSION_STUB')),
        ),
        GoRoute(
          path: RoutePaths.explore,
          builder: (context, state) =>
              const Scaffold(body: Text('EXPLORE_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpPicker(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the card, search and CTA from the design',
      (tester) async {
    await pumpPicker(tester);

    expect(find.text('Location Details'), findsOneWidget);
    expect(find.text(_FakeLocationRepository.pinned.address), findsOneWidget);
    expect(find.text('Search Location'), findsOneWidget);
    expect(find.text('Choose location'), findsOneWidget);
    expect(find.byIcon(Icons.place), findsOneWidget);
  });

  testWidgets('"Choose location" lands in the shell', (tester) async {
    await pumpPicker(tester);

    await tester.tap(find.byKey(const Key('location_choose_button')));
    await tester.pumpAndSettle();

    expect(find.text('EXPLORE_STUB'), findsOneWidget);
  });

  testWidgets('the back arrow returns to the greeting screen',
      (tester) async {
    await pumpPicker(tester);

    await tester.tap(find.byKey(const Key('location_picker_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('PERMISSION_STUB'), findsOneWidget);
  });

  testWidgets('a submitted search replaces the address', (tester) async {
    await pumpPicker(tester);

    await tester.enterText(
      find.byKey(const Key('location_search_field')),
      'Mawar',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Mawar, Kota Yogyakarta'), findsOneWidget);
    expect(find.text(_FakeLocationRepository.pinned.address), findsNothing);
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpPicker(tester);

    // Banner + inline retry — the same message shows up in both places, so
    // the snackbar is matched through its own widget.
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(networkMessage),
      ),
      findsOneWidget,
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Choose location'), findsOneWidget);

    // Nothing to confirm yet, so the CTA stays disabled.
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('location_choose_button')))
          .onPressed,
      isNull,
    );

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text(_FakeLocationRepository.pinned.address), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('location_choose_button')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('a failed search keeps the current address and banners',
      (tester) async {
    await pumpPicker(tester);
    repository.failSearch = true;

    await tester.enterText(
      find.byKey(const Key('location_search_field')),
      'Kricak',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(networkMessage),
      ),
      findsOneWidget,
    );
    expect(find.text(_FakeLocationRepository.pinned.address), findsOneWidget);
    expect(find.text('Kricak, Kota Yogyakarta'), findsNothing);
  });
}
