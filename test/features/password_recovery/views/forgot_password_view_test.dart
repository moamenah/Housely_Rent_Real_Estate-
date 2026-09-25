import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/password_recovery/models/recovery_contact.dart';
import 'package:housely/features/password_recovery/repositories/password_recovery_repository.dart';
import 'package:housely/features/password_recovery/viewmodels/password_recovery_cubit.dart';
import 'package:housely/features/password_recovery/views/forgot_password_view.dart';
import 'package:housely/features/password_recovery/views/widgets/contact_option_card.dart';

/// Behavioural fake: returns the masked options unless [failLoad] is armed,
/// which is how the retry path gets exercised.
class _FakePasswordRecoveryRepository implements PasswordRecoveryRepository {
  bool failLoad = false;

  @override
  Future<List<RecoveryContact>> getRecoveryContacts() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return const [
      RecoveryContact(
        id: 'phone',
        label: 'Via phone',
        maskedValue: '+62 85 -5***488-65',
      ),
      RecoveryContact(
        id: 'email',
        label: 'Via email',
        maskedValue: 'mu***@gmail.com',
      ),
    ];
  }

  @override
  Future<void> verifyCode({
    required String contactId,
    required String code,
  }) async {
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late GoRouter router;
  late _FakePasswordRecoveryRepository repository;

  void setUpRouter() {
    repository = _FakePasswordRecoveryRepository();
    router = GoRouter(
      initialLocation: RoutePaths.forgotPassword,
      routes: [
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (context, state) => BlocProvider(
            create: (_) => PasswordRecoveryCubit(
              repository: repository,
            )..loadContacts(),
            child: const ForgotPasswordView(),
          ),
        ),
        GoRoute(
          path: RoutePaths.verifyCode,
          builder: (context, state) =>
              const Scaffold(body: Text('VERIFY_STUB')),
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

  Future<void> pumpForgotPassword(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  List<ContactOptionCard> cards(WidgetTester tester) => tester
      .widgetList<ContactOptionCard>(find.byType(ContactOptionCard))
      .toList();

  testWidgets('renders both masked contact options from the design',
      (tester) async {
    await pumpForgotPassword(tester);

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(
      find.text(
        'Select which contact details should we use\n'
        'to reset your password',
      ),
      findsOneWidget,
    );
    expect(find.text('Via phone'), findsOneWidget);
    expect(find.text('+62 85 -5***488-65'), findsOneWidget);
    expect(find.text('Via email'), findsOneWidget);
    expect(find.text('mu***@gmail.com'), findsOneWidget);

    // The design opens with the email option already outlined.
    expect(cards(tester)[1].selected, isTrue);
    expect(cards(tester)[0].selected, isFalse);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('tapping the phone row moves the selection', (tester) async {
    await pumpForgotPassword(tester);

    await tester.tap(find.text('Via phone'));
    await tester.pump();

    expect(cards(tester)[0].selected, isTrue);
    expect(cards(tester)[1].selected, isFalse);
  });

  testWidgets('Continue opens the code screen', (tester) async {
    await pumpForgotPassword(tester);

    await tester.tap(find.byKey(const Key('forgot_password_continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('VERIFY_STUB'), findsOneWidget);
  });

  testWidgets('the back arrow returns to sign-in when nothing was pushed',
      (tester) async {
    await pumpForgotPassword(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_outlined));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });

  testWidgets('a failed load announces itself and can be retried',
      (tester) async {
    repository.failLoad = true;
    await pumpForgotPassword(tester);

    // Transport problems get a snackbar plus an inline retry — never a red
    // card, which the design only uses for selection. The same message shows
    // up in both places, so the snackbar is matched through its own widget.
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(
          'No internet connection. Check your network and try again.',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('+62 85 -5***488-65'), findsNothing);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('+62 85 -5***488-65'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });
}
