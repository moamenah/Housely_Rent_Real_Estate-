import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/auth/models/user.dart';
import 'package:housely/features/auth/repositories/auth_repository.dart';
import 'package:housely/features/auth/viewmodels/login_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const validEmail = 'brooklynsim@gmail.com';
  const validPassword = 'housely123';

  late _MockAuthRepository repository;

  LoginCubit buildCubit() => LoginCubit(authRepository: repository);

  setUp(() => repository = _MockAuthRepository());

  void fillValidCredentials(LoginCubit cubit) {
    cubit.emailChanged(validEmail);
    cubit.passwordChanged(validPassword);
  }

  group('field editing', () {
    test('starts with a masked password and a ticked "remember me"', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.email, isEmpty);
      expect(cubit.state.obscurePassword, isTrue);
      expect(cubit.state.rememberMe, isTrue);
      expect(cubit.state.status, RequestStatus.initial);
    });

    test('typing in the email field clears its validation error', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.submit();
      expect(cubit.state.emailError, 'Email is required.');

      cubit.emailChanged(' $validEmail ');
      expect(cubit.state.emailError, isNull);
      // The raw value is kept in state; normalization happens in the
      // repository (and the validator trims before matching).
      expect(cubit.state.email, ' $validEmail ');
      expect(cubit.state.emailError, isNull);
    });

    test('typing in the password field clears its validation error', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.emailChanged(validEmail);
      await cubit.submit();
      expect(cubit.state.passwordError, 'Password is required.');

      cubit.passwordChanged('secret');
      expect(cubit.state.passwordError, isNull);
    });

    test('toggles visibility and remember-me without touching the rest',
        () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleObscurePassword();
      expect(cubit.state.obscurePassword, isFalse);

      cubit.toggleRememberMe();
      expect(cubit.state.rememberMe, isFalse);
      expect(cubit.state.obscurePassword, isFalse);
    });
  });

  group('local validation', () {
    test('rejects a malformed email without calling the repository', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.emailChanged('not-an-email');
      cubit.passwordChanged(validPassword);
      await cubit.submit();

      expect(cubit.state.emailError, 'Enter a valid email address.');
      expect(cubit.state.status, RequestStatus.initial);
      verifyNever(
        () => repository.signIn(
          email: 'not-an-email',
          password: validPassword,
        ),
      );
    });

    test('requires a password before spending a round-trip', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.emailChanged(validEmail);
      await cubit.submit();

      expect(cubit.state.passwordError, 'Password is required.');
      verifyNever(
        () => repository.signIn(email: validEmail, password: ''),
      );
    });
  });

  group('submit', () {
    test('reports loading while in flight and ignores a double tap',
        () async {
      final gate = Completer<User>();
      var calls = 0;
      when(() => repository.signIn(
            email: validEmail,
            password: validPassword,
          )).thenAnswer((_) {
        calls += 1;
        return gate.future;
      });

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidCredentials(cubit);

      final firstRun = cubit.submit();
      expect(cubit.state.isLoading, isTrue);

      await cubit.submit(); // re-entry guard
      expect(calls, 1);

      gate.complete(const User(email: validEmail));
      await firstRun;

      expect(cubit.state.isAuthenticated, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.user?.email, validEmail);
    });

    test('a rejected password becomes an inline field error, not a banner',
        () async {
      when(() => repository.signIn(email: validEmail, password: 'wrong-pass'))
          .thenThrow(const InvalidCredentialsException());

      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.emailChanged(validEmail);
      cubit.passwordChanged('wrong-pass');
      await cubit.submit();

      expect(cubit.state.hasFailed, isTrue);
      expect(cubit.state.passwordError, 'The entered password is wrong !');
      // No banner material — the error lives under the field, as in the design.
      expect(cubit.state.failure, isNull);
    });

    test('a transport failure stays out of the field and surfaces as a Failure',
        () async {
      when(() => repository.signIn(email: validEmail, password: validPassword))
          .thenThrow(const NetworkException());

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidCredentials(cubit);
      await cubit.submit();

      expect(cubit.state.hasFailed, isTrue);
      expect(cubit.state.passwordError, isNull);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('a successful sign-in stores the session user', () async {
      when(() => repository.signIn(email: validEmail, password: validPassword))
          .thenAnswer((_) async => const User(email: validEmail));

      final cubit = buildCubit();
      addTearDown(cubit.close);
      fillValidCredentials(cubit);
      await cubit.submit();

      expect(cubit.state.isAuthenticated, isTrue);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.user, const User(email: validEmail));
      verify(() => repository.signIn(
            email: validEmail,
            password: validPassword,
          )).called(1);
    });
  });
}
