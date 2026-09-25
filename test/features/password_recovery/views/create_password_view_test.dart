import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/password_recovery/models/recovery_contact.dart';
import 'package:housely/features/password_recovery/repositories/password_recovery_repository.dart';
import 'package:housely/features/password_recovery/viewmodels/password_recovery_cubit.dart';
import 'package:housely/features/password_recovery/views/create_password_view.dart';

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
      initialLocation: RoutePaths.resetPassword,
      routes: [
        GoRoute(
          path: RoutePaths.resetPassword,
          builder: (context, state) => BlocProvider(
            create: (_) => PasswordRecoveryCubit(
              repository: repository,
            )..loadContacts(),
            child: const CreatePasswordView(),
          ),
        ),
        GoRoute(
          path: RoutePaths.passwordChanged,
          builder: (context, state) =>
              const Scaffold(body: Text('SUCCESS_STUB')),
        ),
        GoRoute(
          path: RoutePaths.verifyCode,
          builder: (context, state) =>
              const Scaffold(body: Text('VERIFY_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpCreatePassword(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  /// Dismisses the focused field (and its cursor-handle overlay) before any
  /// button tap, exactly as tapping outside would in the real app.
  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  testWidgets('renders the design copy with both fields masked',
      (tester) async {
    await pumpCreatePassword(tester);

    expect(find.text('Create New Password'), findsOneWidget);
    expect(
      find.text('Please enter a new password\nto change'),
      findsOneWidget,
    );
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Password'), findsNWidgets(2));

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList(growable: false);
    expect(fields[0].obscureText, isTrue);
    expect(fields[1].obscureText, isTrue);
    expect(find.text('Change password'), findsOneWidget);
  });

  testWidgets('an empty submit marks both fields inline', (tester) async {
    await pumpCreatePassword(tester);

    await tester.tap(find.byKey(const Key('reset_change_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('New password is required.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
    expect(find.text('SUCCESS_STUB'), findsNothing);
  });

  testWidgets('a mismatch marks only the confirmation field', (tester) async {
    await pumpCreatePassword(tester);

    await tester.enterText(
      find.byKey(const Key('reset_new_password_field')),
      'housely123',
    );
    await tester.enterText(
      find.byKey(const Key('reset_confirm_password_field')),
      'housely12',
    );
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('reset_change_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(find.text('New password is required.'), findsNothing);
    expect(find.text('SUCCESS_STUB'), findsNothing);
  });

  testWidgets('matching passwords reach the success screen', (tester) async {
    await pumpCreatePassword(tester);

    await tester.enterText(
      find.byKey(const Key('reset_new_password_field')),
      'housely123',
    );
    await tester.enterText(
      find.byKey(const Key('reset_confirm_password_field')),
      'housely123',
    );
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('reset_change_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('SUCCESS_STUB'), findsOneWidget);
  });

  testWidgets('the eye toggles unmask each field independently',
      (tester) async {
    await pumpCreatePassword(tester);

    await tester.tap(find.byKey(const Key('reset_obscure_toggle')));
    await tester.pump();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList(growable: false);
    expect(fields[0].obscureText, isFalse);
    expect(fields[1].obscureText, isTrue);
  });

  testWidgets('the back arrow returns to the code screen', (tester) async {
    await pumpCreatePassword(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_outlined));
    await tester.pumpAndSettle();

    expect(find.text('VERIFY_STUB'), findsOneWidget);
  });
}
