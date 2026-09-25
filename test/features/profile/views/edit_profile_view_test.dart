import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/routing/route_paths.dart';
import 'package:housely/core/theme/app_theme.dart';
import 'package:housely/features/profile/models/profile.dart';
import 'package:housely/features/profile/repositories/profile_repository.dart';
import 'package:housely/features/profile/views/edit_profile_view.dart';

/// Behavioural fake: returns the demo account unless the test arms
/// [failLoad] / [failSave].
class _FakeProfileRepository implements ProfileRepository {
  bool failLoad = false;
  bool failSave = false;

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
    if (failSave) {
      throw const NetworkException();
    }
    return Profile(
      name: name.trim(),
      username: username.trim(),
      email: email.trim(),
      dateOfBirth: dateOfBirth,
    );
  }
}

void main() {
  const networkMessage =
      'No internet connection. Check your network and try again.';

  late GoRouter router;
  late _FakeProfileRepository repository;

  void setUpRouter() {
    repository = _FakeProfileRepository();
    router = GoRouter(
      initialLocation: RoutePaths.profileEdit,
      routes: [
        GoRoute(
          path: RoutePaths.profileEdit,
          builder: (context, state) =>
              EditProfileView(profileRepository: repository),
        ),
        GoRoute(
          path: RoutePaths.profile,
          builder: (context, state) =>
              const Scaffold(body: Text('PROFILE_STUB')),
        ),
      ],
    );
  }

  setUp(setUpRouter);
  tearDown(() => router.dispose());

  Future<void> pumpEditProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  /// Fields are focused while editing, so the keyboard state is cleared
  /// before any CTA tap (mirrors the real flow's unfocus-on-submit).
  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  testWidgets('pre-fills every field from the stored account',
      (tester) async {
    await pumpEditProfile(tester);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);

    expect(
      find.widgetWithText(
        TextField,
        'Brooklyn Simmons',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'brooklynsim'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'brooklynsim@gmail.com'),
      findsOneWidget,
    );
    // The design's date format, exactly.
    expect(find.text('November/21/1992'), findsOneWidget);
    expect(find.text('Save Change'), findsOneWidget);
  });

  testWidgets('clearing a field blocks the save with an inline message',
      (tester) async {
    await pumpEditProfile(tester);

    await tester.enterText(
      find.byKey(const Key('edit_profile_name_field')),
      '',
    );
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('PROFILE_STUB'), findsNothing);
    // Field problems are local — never announced as a banner.
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a malformed email is rejected inline', (tester) async {
    await pumpEditProfile(tester);

    await tester.enterText(
      find.byKey(const Key('edit_profile_email_field')),
      'not-an-email',
    );
    await unfocus(tester);
    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('PROFILE_STUB'), findsNothing);
  });

  testWidgets('a valid form saves and steps back to Profile', (tester) async {
    await pumpEditProfile(tester);

    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Your profile has been updated.'),
      findsOneWidget,
    );
    expect(find.text('PROFILE_STUB'), findsOneWidget);
  });

  testWidgets('a save failure banners and keeps the form on screen',
      (tester) async {
    await pumpEditProfile(tester);
    repository.failSave = true;

    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(networkMessage),
      ),
      findsOneWidget,
    );
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('PROFILE_STUB'), findsNothing);
  });

  testWidgets('the calendar opens the date picker and accepts a new date',
      (tester) async {
    await pumpEditProfile(tester);

    await tester.tap(find.byKey(const Key('edit_profile_dob_field')));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('November/15/1992'), findsOneWidget);
    expect(find.text('November/21/1992'), findsNothing);
  });

  testWidgets('the camera badge is an honest stub', (tester) async {
    await pumpEditProfile(tester);

    await tester.tap(find.byKey(const Key('edit_profile_avatar')));
    await tester.pumpAndSettle();

    expect(
      find.text("Changing your photo isn't available in this build yet."),
      findsOneWidget,
    );
    expect(find.text('PROFILE_STUB'), findsNothing);
  });

  testWidgets('the back arrow returns to the Profile tab', (tester) async {
    await pumpEditProfile(tester);

    await tester.tap(find.byKey(const Key('edit_profile_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('PROFILE_STUB'), findsOneWidget);
  });
}
