import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/auth/models/user.dart';
import 'package:housely/features/auth/repositories/auth_repository.dart';
import 'package:housely/features/auth/views/sign_up_view.dart';

/// Behavioural fake: registration always succeeds unless the test arms
/// [failNextSubmit], which is how the banner path gets exercised.
class _FakeAuthRepository implements AuthRepository {
  bool failNextSubmit = false;

  @override
  Future<User> signIn({required String email, required String password}) async {
    await Future<void>.delayed(Duration.zero);
    return User(email: email);
  }

  @override
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (failNextSubmit) {
      throw const NetworkException();
    }
    return User(email: email, username: username);
  }
}

void main() {
  late GoRouter router;
  late _FakeAuthRepository repository;

  void setUpRouter() {
    repository = _FakeAuthRepository();
    router = GoRouter(
      initialLocation: RoutePaths.signup,
      routes: [
        GoRoute(
          path: RoutePaths.signup,
          builder: (context, state) =>
              SignUpView(authRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) =>
              const Scaffold(body: Text('LOGIN_STUB')),
        ),
        GoRoute(
          path: RoutePaths.locationPermission,
          builder: (context, state) =>
              const Scaffold(body: Text('LOCATION_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpSignUp(WidgetTester tester) async {
    // A real phone viewport so the CTA is on screen — taps must not depend
    // on scrolling.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('signup_email_field')),
      'brooklynsim@gmail.com',
    );
    await tester.enterText(
      find.byKey(const Key('signup_username_field')),
      'brooklyn',
    );
    await tester.enterText(
      find.byKey(const Key('signup_password_field')),
      'housely123',
    );
  }

  Future<void> submitForm(WidgetTester tester) async {
    // A focused field renders its cursor-handle overlay *above* the route,
    // and it can land on top of the CTA once the view scrolls — dismiss it
    // first, the way tapping outside the field would in the real app.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final button = find.byKey(const Key('signup_sign_up_button'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('renders every section of the design', (tester) async {
    await pumpSignUp(tester);

    expect(find.text('Register Account'), findsOneWidget);
    expect(
      find.text(
        'Sign in with your email and password\nor social media to continue',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
    expect(find.byKey(const Key('signup_username_field')), findsOneWidget);
    expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
    // Each field shows a caption *and* a hint, so count loosely.
    expect(find.text('Username'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
    // The terms line is rich text (bold segments) — match on its spans.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan?.toPlainText() == 'Agree with terms and privacy',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('signup_terms_checkbox')), findsOneWidget);
    expect(find.text('Or'), findsOneWidget);
    expect(find.text('Already have an account ?'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('password is masked by default and the toggle unmasks it',
      (tester) async {
    await pumpSignUp(tester);

    final passwordField = tester.widget<TextField>(
      find.byKey(const Key('signup_password_field')),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('signup_obscure_toggle')));
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('signup_password_field')))
          .obscureText,
      isFalse,
    );
  });

  testWidgets('empty submit validates every field inline', (tester) async {
    await pumpSignUp(tester);

    await submitForm(tester);

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Username is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('LOCATION_STUB'), findsNothing);
  });

  testWidgets('unticking the terms box blocks the submit with its own message',
      (tester) async {
    await pumpSignUp(tester);
    await fillForm(tester);

    await tester.tap(find.byKey(const Key('signup_terms_checkbox')));
    await tester.pump();
    expect(
      tester
          .widget<Checkbox>(find.byKey(const Key('signup_terms_checkbox')))
          .value,
      isFalse,
    );

    await submitForm(tester);

    expect(
      find.text('You must agree to the terms to continue.'),
      findsOneWidget,
    );
    expect(find.text('LOCATION_STUB'), findsNothing);
  });

  testWidgets('a valid form registers and opens the location step',
      (tester) async {
    await pumpSignUp(tester);
    await fillForm(tester);

    await submitForm(tester);

    expect(find.text('LOCATION_STUB'), findsOneWidget);
    expect(find.text('Register Account'), findsNothing);
  });

  testWidgets('a repository failure surfaces as a banner, not a field error',
      (tester) async {
    repository.failNextSubmit = true;
    await pumpSignUp(tester);
    await fillForm(tester);

    await submitForm(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('LOCATION_STUB'), findsNothing);
    expect(find.text('Email is required.'), findsNothing);
    expect(find.text('Password is required.'), findsNothing);
  });

  testWidgets('the back arrow returns to sign-in when nothing was pushed',
      (tester) async {
    await pumpSignUp(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_outlined));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });

  testWidgets('the sign-in link opens the sign-in screen', (tester) async {
    await pumpSignUp(tester);

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });
}
