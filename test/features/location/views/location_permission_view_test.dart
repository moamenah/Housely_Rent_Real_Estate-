import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/location/views/location_permission_view.dart';

void main() {
  late GoRouter router;

  void setUpRouter() {
    router = GoRouter(
      initialLocation: RoutePaths.locationPermission,
      routes: [
        GoRoute(
          path: RoutePaths.locationPermission,
          builder: (context, state) => const LocationPermissionView(),
        ),
        GoRoute(
          path: RoutePaths.locationPicker,
          builder: (context, state) =>
              const Scaffold(body: Text('PICKER_STUB')),
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

  Future<void> pumpPermission(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every section of the design', (tester) async {
    await pumpPermission(tester);

    expect(find.text('Hi, Nice to meet you !'), findsOneWidget);
    expect(
      find.text('Choose your location to find property around you'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.byKey(const Key('location_use_current_button')), findsOneWidget);
    expect(find.text('Use current location'), findsOneWidget);
    expect(find.byKey(const Key('location_manual_button')), findsOneWidget);
    expect(find.text('Select it manually'), findsOneWidget);
  });

  testWidgets('Skip jumps straight into the shell', (tester) async {
    await pumpPermission(tester);

    await tester.tap(find.byKey(const Key('location_skip_button')));
    await tester.pumpAndSettle();

    expect(find.text('EXPLORE_STUB'), findsOneWidget);
  });

  testWidgets('"Select it manually" opens the map', (tester) async {
    await pumpPermission(tester);

    await tester.tap(find.byKey(const Key('location_manual_button')));
    await tester.pumpAndSettle();

    expect(find.text('PICKER_STUB'), findsOneWidget);
  });

  testWidgets('"Use current location" is an honest stub with a banner',
      (tester) async {
    await pumpPermission(tester);

    await tester.tap(find.byKey(const Key('location_use_current_button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Using your current location isn't available in this build yet.",
      ),
      findsOneWidget,
    );
    // The stub must not pretend to have a position — the user stays here.
    expect(find.text('EXPLORE_STUB'), findsNothing);
    expect(find.text('PICKER_STUB'), findsNothing);
  });
}
