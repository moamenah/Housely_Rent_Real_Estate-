import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/auth/models/user.dart';
import 'package:housely/features/auth/repositories/auth_repository.dart';
import 'package:housely/features/auth/views/login_view.dart';
import 'package:housely/features/auth/views/widgets/social_button.dart';

/// Behavioural fake: accepts [demoPassword], rejects everything else the way
/// the mock backend does. Sign-up always succeeds here (it has no error state
/// in the design).
class _FakeAuthRepository implements AuthRepository {
  static const demoPassword = 'housely123';

  @override
  Future<User> signIn({required String email, required String password}) async {
    await Future<void>.delayed(Duration.zero);
    if (password != demoPassword) {
      throw const InvalidCredentialsException();
    }
    return User(email: email);
  }

  @override
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(Duration.zero);
    return User(email: email, username: username);
  }
}

void main() {
  late GoRouter router;

  void setUpRouter() {
    final repository = _FakeAuthRepository();
    router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) =>
              LoginView(authRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.signup,
          builder: (context, state) =>
              const Scaffold(body: Text('SIGNUP_STUB')),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (context, state) =>
              const Scaffold(body: Text('FORGOT_PASSWORD_STUB')),
        ),
        GoRoute(
          path: RoutePaths.locationPermission,
          builder: (context, state) =>
              const Scaffold(body: Text('LOCATION_STUB')),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) =>
              const Scaffold(body: Text('ONBOARDING_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpLogin(WidgetTester tester) async {
    // A real phone viewport so the whole form (and its CTA) is on screen —
    // taps must not depend on scrolling.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every section of the design', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Welcome Back !'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot password ?'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Or'), findsOneWidget);
    expect(find.text("Don't have account ?"), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
  });

  testWidgets('password is masked by default and the toggle unmasks it',
      (tester) async {
    await pumpLogin(tester);

    final passwordField = tester.widget<TextField>(
      find.byKey(const Key('login_password_field')),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('login_obscure_toggle')));
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('login_password_field')))
          .obscureText,
      isFalse,
    );
  });

  testWidgets('empty submit validates both fields inline', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('LOCATION_STUB'), findsNothing);
  });

  testWidgets('a wrong password shows the designed field error',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'brooklynsim@gmail.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'definitely-wrong',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('The entered password is wrong !'), findsOneWidget);
    expect(find.text('LOCATION_STUB'), findsNothing);
  });

  testWidgets('editing the password clears the field error', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'brooklynsim@gmail.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('The entered password is wrong !'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'housely123',
    );
    await tester.pumpAndSettle();
    expect(find.text('The entered password is wrong !'), findsNothing);
  });

  testWidgets('valid credentials sign in and open the location step',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'brooklynsim@gmail.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'housely123',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('LOCATION_STUB'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('the back arrow returns to onboarding when nothing was pushed',
      (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_outlined));
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING_STUB'), findsOneWidget);
  });

  testWidgets('the sign-up link opens the register screen', (tester) async {
    await pumpLogin(tester);

    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('SIGNUP_STUB'), findsOneWidget);
  });

  testWidgets('the forgot-password link opens the recovery flow',
      (tester) async {
    await pumpLogin(tester);

    await tester.ensureVisible(find.text('Forgot password ?'));
    await tester.tap(find.text('Forgot password ?'));
    await tester.pumpAndSettle();

    expect(find.text('FORGOT_PASSWORD_STUB'), findsOneWidget);
  });

  testWidgets('social sign-in is stubbed with a snackbar', (tester) async {
    await pumpLogin(tester);

    // The buttons are icon-only circles (Facebook comes first); the label
    // only exists in the widget's semantics.
    final facebook = find.byType(SocialButton).first;
    await tester.ensureVisible(facebook);
    await tester.tap(facebook);
    await tester.pumpAndSettle();

    expect(
      find.text("Facebook sign-in isn't available in this build yet."),
      findsOneWidget,
    );
  });
}
