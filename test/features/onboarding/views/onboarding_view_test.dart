import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/features/onboarding/models/onboarding_page.dart';
import 'package:housely/features/onboarding/views/onboarding_view.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: RoutePaths.onboarding,
      routes: [
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) =>
              const Scaffold(body: Text('LOGIN_STUB')),
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  testWidgets('renders the first page with Skip and a Next CTA',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingPage.pages.first.title, findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.byKey(const Key('onboarding_primary_cta')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-dot-0')), findsOneWidget);
  });

  testWidgets('Next walks the pages and turns into Get started on the last',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    for (var i = 1; i < OnboardingPage.pages.length; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Get started'), findsOneWidget);
    expect(
      find.text(OnboardingPage.pages.last.title, findRichText: true),
      findsOneWidget,
    );
    expect(find.text('LOGIN_STUB'), findsNothing);
  });

  testWidgets('Get started on the last page moves on to login', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
  });

  testWidgets('Skip jumps straight to login, from the first page',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });
}
