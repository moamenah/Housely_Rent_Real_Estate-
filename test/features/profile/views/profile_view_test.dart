import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/profile/models/profile.dart';
import 'package:housely/features/profile/repositories/profile_repository.dart';
import 'package:housely/features/profile/views/profile_view.dart';
import 'package:housely/features/profile/views/widgets/profile_avatar.dart';

/// Behavioural fake: returns the demo account unless [failLoad] is armed,
/// which is how the retry path gets exercised.
class _FakeProfileRepository implements ProfileRepository {
  bool failLoad = false;

  @override
  Future<Profile> getProfile() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return Profile(
      name: 'Brooklyn Simmons',
      username: 'brooklynsim',
      email: 'brooklynsim@gmail.com',
      dateOfBirth: DateTime(1992, 11, 21),
    );
  }

  @override
  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  }) async {
    await Future<void>.delayed(Duration.zero);
    return Profile(
      name: name,
      username: username,
      email: email,
      dateOfBirth: dateOfBirth,
    );
  }
}

void main() {
  late GoRouter router;
  late _FakeProfileRepository repository;

  void setUpRouter() {
    repository = _FakeProfileRepository();
    router = GoRouter(
      initialLocation: RoutePaths.profile,
      routes: [
        GoRoute(
          path: RoutePaths.profile,
          builder: (context, state) =>
              ProfileView(profileRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.profileEdit,
          builder: (context, state) =>
              const Scaffold(body: Text('EDIT_STUB')),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) =>
              const Scaffold(body: Text('LOGIN_STUB')),
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

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every section of the design', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text('Brooklyn Simmons'), findsOneWidget);
    expect(find.text('brooklynsim@gmail.com'), findsOneWidget);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Recent Viewed'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('tapping the portrait opens Edit Profile', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('profile_avatar_button')));
    await tester.pumpAndSettle();

    expect(find.text('EDIT_STUB'), findsOneWidget);
  });

  testWidgets('the settings rows are stubbed with a banner', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(
      find.text("Payment isn't available in this build yet."),
      findsOneWidget,
    );
    expect(find.text('EDIT_STUB'), findsNothing);
  });

  testWidgets('Sign Out returns to the sign-in screen', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('profile_sign_out_button')));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });

  testWidgets('the back arrow falls into the shell', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('profile_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('EXPLORE_STUB'), findsOneWidget);
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpProfile(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Brooklyn Simmons'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Brooklyn Simmons'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });
}
