import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/password_recovery/views/password_changed_view.dart';

void main() {
  late GoRouter router;

  void setUpRouter() {
    router = GoRouter(
      initialLocation: RoutePaths.passwordChanged,
      routes: [
        GoRoute(
          path: RoutePaths.passwordChanged,
          builder: (context, state) => const PasswordChangedView(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) =>
              const Scaffold(body: Text('LOGIN_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  testWidgets('shows the success illustration and copy', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    expect(find.text('Success!'), findsOneWidget);
    expect(
      find.text(
        'Your password has been changed.\n'
        'Please log in again with a new password',
      ),
      findsOneWidget,
    );
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // Terminal screen: no back arrow, nothing to pop.
    expect(find.byIcon(Icons.arrow_back_outlined), findsNothing);
  });

  testWidgets('Continue returns to sign-in', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('password_changed_continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });
}
