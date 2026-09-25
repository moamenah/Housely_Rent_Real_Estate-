import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/di/injection.dart';
import 'package:housely/core/routing/app_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/profile/views/widgets/profile_avatar.dart';

/// End-to-end check of the design's five-tab shell, using the real router
/// and the real (mock) data layer.
///
/// Explore/Favorites are deliberately not visited: their card images are
/// network assets, and this file only proves the bar's structure and
/// branch-switching — property rendering has its own cubit tests.
void main() {
  setUpAll(() async {
    await configureDependencies();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: appRouter, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    // Let the splash's minimum display time elapse (its Cubit would otherwise
    // emit after being disposed by the jump below), then enter the shell.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    appRouter.go(RoutePaths.home);
    await tester.pumpAndSettle();
  }

  testWidgets('the bar shows all five tabs from the design', (tester) async {
    await pumpShell(tester);

    // Home renders its placeholder, so 'Home' exists twice: title + tab.
    expect(find.text('Home'), findsNWidgets(2));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('My Booking'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping tabs switches branches across the shell',
      (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('My Booking'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Bookings aren't part of this build yet — "
        'your visits will be listed here once booking ships.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text('Brooklyn Simmons'), findsOneWidget);
    expect(find.text('brooklynsim@gmail.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    // Title + tab label.
    expect(find.text('Profile'), findsNWidgets(2));

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Your home feed isn't part of this build yet — "
        'the full listing feed lives in the Explore tab.',
      ),
      findsOneWidget,
    );
  });
}
