import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/password_recovery/models/recovery_contact.dart';
import 'package:housely/features/password_recovery/repositories/password_recovery_repository.dart';
import 'package:housely/features/password_recovery/viewmodels/password_recovery_cubit.dart';
import 'package:housely/features/password_recovery/views/verify_code_view.dart';
import 'package:housely/features/password_recovery/views/widgets/otp_input.dart';

class _FakePasswordRecoveryRepository implements PasswordRecoveryRepository {
  @override
  Future<List<RecoveryContact>> getRecoveryContacts() async {
    await Future<void>.delayed(Duration.zero);
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
      initialLocation: RoutePaths.verifyCode,
      routes: [
        GoRoute(
          path: RoutePaths.verifyCode,
          builder: (context, state) => BlocProvider(
            create: (_) => PasswordRecoveryCubit(
              repository: repository,
            )..loadContacts(),
            child: const VerifyCodeView(),
          ),
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          builder: (context, state) =>
              const Scaffold(body: Text('RESET_STUB')),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (context, state) =>
              const Scaffold(body: Text('FORGOT_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpVerifyCode(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  /// Leaves the focused OTP field the way tapping elsewhere would, so the
  /// cursor-handle overlay cannot swallow the button tap that follows.
  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  testWidgets('renders the design copy around one hidden six-digit field',
      (tester) async {
    await pumpVerifyCode(tester);

    expect(find.text('Verify your Email'), findsOneWidget);
    expect(
      find.text(
        'Please enter 6 digit verification that\n'
        'have been sent to your email address',
      ),
      findsOneWidget,
    );
    expect(find.byType(OtpInput), findsOneWidget);
    expect(find.text("Didn't receive code ?"), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('RESET_STUB'), findsNothing);
  });

  testWidgets('typing shows the digits in the boxes', (tester) async {
    await pumpVerifyCode(tester);

    await tester.enterText(find.byType(TextField), '54');
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('a short code stays on the screen with the inline message',
      (tester) async {
    await pumpVerifyCode(tester);

    await tester.enterText(find.byType(TextField), '12345');
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('verify_code_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the 6 digit code.'), findsOneWidget);
    expect(find.text('RESET_STUB'), findsNothing);
  });

  testWidgets('a complete code advances to the new-password step',
      (tester) async {
    await pumpVerifyCode(tester);

    await tester.enterText(find.byType(TextField), '548412');
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('verify_code_button')));
    await tester.pumpAndSettle();

    expect(find.text('RESET_STUB'), findsOneWidget);
  });

  testWidgets('the back arrow returns to the contact list', (tester) async {
    await pumpVerifyCode(tester);

    await unfocus(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_outlined));
    await tester.pumpAndSettle();

    expect(find.text('FORGOT_STUB'), findsOneWidget);
  });

  testWidgets('Resend code is stubbed with a snackbar', (tester) async {
    await pumpVerifyCode(tester);

    await unfocus(tester);
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();

    expect(
      find.text("Resend code isn't available in this build yet."),
      findsOneWidget,
    );
    expect(find.text('RESET_STUB'), findsNothing);
  });
}
