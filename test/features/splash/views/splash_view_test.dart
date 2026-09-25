import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/features/splash/views/splash_view.dart';

void main() {
  testWidgets('shows the brand screen, then replaces it with onboarding',
      (tester) async {
    final router = GoRouter(
      initialLocation: RoutePaths.splash,
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => SplashView(bootstrap: () async {}),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) =>
              const Scaffold(body: Text('ONBOARDING_STUB')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Intro animation (1600ms) is playing.
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('HOUSELY'), findsOneWidget);

    // Minimum display time (1800ms) elapses → the Cubit reports ready.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING_STUB'), findsOneWidget);
    expect(find.text('HOUSELY'), findsNothing);
  });
}
