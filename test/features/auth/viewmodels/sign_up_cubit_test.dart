import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/auth/models/user.dart';
import 'package:housely/features/auth/repositories/auth_repository.dart';
import 'package:housely/features/auth/viewmodels/sign_up_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const validEmail = 'brooklynsim@gmail.com';
  const validUsername = 'brooklyn';
  const validPassword = 'housely123';

  late _MockAuthRepository repository;

  SignUpCubit buildCubit() => SignUpCubit(authRepository: repository);

  setUp(() => repository = _MockAuthRepository());

  void fillValidForm(SignUpCubit cubit) {
    cubit.emailChanged(validEmail);
    cubit.usernameChanged(validUsername);
    cubit.passwordChanged(validPassword);
  }

  group('field editing', () {
    test('starts with a masked password and a ticked terms box', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.email, isEmpty);
      expect(cubit.state.username, isEmpty);
      expect(cubit.state.password, isEmpty);
      expect(cubit.state.obscurePassword, isTrue);
      expect(cubit.state.agreeToTerms, isTrue);
      expect(cubit.state.status, RequestStatus.initial);
    });

    test('a failed submit marks only the empty fields', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.submit();

      expect(cubit.state.emailError, 'Email is required.');
      expect(cubit.state.usernameError, 'Username is required.');
      expect(cubit.state.passwordError, 'Password is required.');
      // The box is ticked by default, so the terms gate stays quiet.
      expect(cubit.state.termsError, isNull);
    });

    test('typing in a field clears that field error only', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.submit();
      cubit.usernameChanged(' $validUsername ');

      expect(cubit.state.usernameError, isNull);
      expect(cubit.state.emailError, 'Email is required.');
      expect(cubit.state.passwordError, 'Password is required.');
      // The raw value is kept in state; the repository trims on the way out.
      expect(cubit.state.username, ' $validUsername ');
    });

    test('toggles visibility and the terms box without touching the rest',
        () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleObscurePassword();
      expect(cubit.state.obscurePassword, isFalse);

      cubit.toggleAgreeToTerms();
      expect(cubit.state.agreeToTerms, isFalse);
      expect(cubit.state.obscurePassword, isFalse);

      // Ticking the box back also clears its stale error.
      cubit.toggleAgreeToTerms();
      expect(cubit.state.agreeToTerms, isTrue);
      expect(cubit.state.termsError, isNull);
    });
  });

  group('local validation', () {
    test('rejects a malformed email without calling the repository', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.emailChanged('not-an-email');
      cubit.usernameChanged(validUsername);
      cubit.passwordChanged(validPassword);
      await cubit.submit();

      expect(cubit.state.emailError, 'Enter a valid email address.');
      expect(cubit.state.status, RequestStatus.initial);
      verifyNever(
        () => repository.signUp(
          email: 'not-an-email',
          username: validUsername,
          password: validPassword,
        ),
      );
    });

    test('requires a username before spending a round-trip', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.emailChanged(validEmail);
      cubit.passwordChanged(validPassword);
      await cubit.submit();

      expect(cubit.state.usernameError, 'Username is required.');
      verifyNever(
        () => repository.signUp(
          email: validEmail,
          username: '',
          password: validPassword,
        ),
      );
    });

    test('blocks the submit until the terms box is ticked', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      fillValidForm(cubit);
      cubit.toggleAgreeToTerms();
      await cubit.submit();

      expect(cubit.state.termsError, 'You must agree to the terms to continue.');
      expect(cubit.state.status, RequestStatus.initial);
      verifyNever(
        () => repository.signUp(
          email: validEmail,
          username: validUsername,
          password: validPassword,
        ),
      );
    });
  });

  group('submit', () {
    test('reports loading while in flight and ignores a double tap',
        () async {
      final gate = Completer<User>();
      var calls = 0;
      when(
        () => repository.signUp(
          email: validEmail,
          username: validUsername,
          password: validPassword,
        ),
      ).thenAnswer((_) {
        calls += 1;
        return gate.future;
      });

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidForm(cubit);

      final firstRun = cubit.submit();
      expect(cubit.state.isLoading, isTrue);

      await cubit.submit(); // re-entry guard
      expect(calls, 1);

      gate.complete(const User(email: validEmail, username: validUsername));
      await firstRun;

      expect(cubit.state.isRegistered, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.user?.username, validUsername);
    });

    test('a transport failure is a banner, never a field error', () async {
      when(
        () => repository.signUp(
          email: validEmail,
          username: validUsername,
          password: validPassword,
        ),
      ).thenThrow(const NetworkException());

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidForm(cubit);
      await cubit.submit();

      expect(cubit.state.hasFailed, isTrue);
      expect(cubit.state.emailError, isNull);
      expect(cubit.state.usernameError, isNull);
      expect(cubit.state.passwordError, isNull);
      expect(cubit.state.termsError, isNull);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('a successful sign-up stores the session user', () async {
      when(
        () => repository.signUp(
          email: validEmail,
          username: validUsername,
          password: validPassword,
        ),
      ).thenAnswer((_) async =>
          const User(email: validEmail, username: validUsername));

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidForm(cubit);
      await cubit.submit();

      expect(cubit.state.isRegistered, isTrue);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.user,
          const User(email: validEmail, username: validUsername));
      verify(
        () => repository.signUp(
          email: validEmail,
          username: validUsername,
          password: validPassword,
        ),
      ).called(1);
    });
  });
}
