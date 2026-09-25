import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/password_recovery/models/recovery_contact.dart';
import 'package:housely/features/password_recovery/repositories/password_recovery_repository.dart';
import 'package:housely/features/password_recovery/viewmodels/password_recovery_cubit.dart';
import 'package:housely/features/password_recovery/viewmodels/password_recovery_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPasswordRecoveryRepository extends Mock
    implements PasswordRecoveryRepository {}

void main() {
  const contacts = [
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

  late _MockPasswordRecoveryRepository repository;

  PasswordRecoveryCubit buildCubit() =>
      PasswordRecoveryCubit(repository: repository);

  setUp(() {
    repository = _MockPasswordRecoveryRepository();
    when(() => repository.getRecoveryContacts())
        .thenAnswer((_) async => contacts);
  });

  group('contact options', () {
    test('load once and preselect the email card, as designed', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.contactsStatus, RequestStatus.initial);

      await cubit.loadContacts();

      expect(cubit.state.contactsStatus, RequestStatus.success);
      expect(cubit.state.contacts, contacts);
      expect(cubit.state.selectedContactId, 'email');
      expect(cubit.state.selectedContact, contacts[1]);
      expect(cubit.state.failure, isNull);
    });

    test('switch the selection without touching anything else', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadContacts();

      cubit.selectContact('phone');

      expect(cubit.state.selectedContactId, 'phone');
      expect(cubit.state.contactsStatus, RequestStatus.success);

      // Re-tapping the active card is a no-op (no needless rebuild).
      cubit.selectContact('phone');
      expect(cubit.state.selectedContactId, 'phone');
    });

    test('a transport failure becomes a banner failure, never a field error',
        () async {
      when(() => repository.getRecoveryContacts())
          .thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadContacts();

      expect(cubit.state.contactsStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.failure?.message, contains('internet connection'));
    });
  });

  group('code entry', () {
    test('keeps the code digits-only and capped at six', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.codeChanged('12ab34');
      expect(cubit.state.code, '1234');

      cubit.codeChanged('123456789');
      expect(cubit.state.code, '123456');
      expect(cubit.state.code.length, PasswordRecoveryState.codeLength);
    });

    test('a short code sets only the inline error and never calls the API',
        () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadContacts();
      cubit.codeChanged('12345');

      await cubit.verifyCode();

      expect(cubit.state.codeError, 'Please enter the 6 digit code.');
      expect(cubit.state.verifyStatus, RequestStatus.initial);
      expect(cubit.state.failure, isNull);
      // Only the contact list was ever fetched — the code never left the UI.
      verify(() => repository.getRecoveryContacts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('a complete code verifies and unlocks the password step', () async {
      when(
        () => repository.verifyCode(contactId: 'email', code: '548412'),
      ).thenAnswer((_) async {});
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadContacts();
      cubit.codeChanged('548412');

      final pending = cubit.verifyCode();
      expect(cubit.state.verifyStatus, RequestStatus.loading);
      expect(cubit.state.isVerifying, isTrue);

      await pending;

      expect(cubit.state.isVerified, isTrue);
      expect(cubit.state.failure, isNull);
      verify(() => repository.verifyCode(contactId: 'email', code: '548412'))
          .called(1);
    });

    test('a transport failure is a banner, not a field error', () async {
      when(
        () => repository.verifyCode(contactId: 'email', code: '548412'),
      ).thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadContacts();
      cubit.codeChanged('548412');

      await cubit.verifyCode();

      expect(cubit.state.verifyStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.codeError, isNull);
    });

    test('retrying after a failure starts from a clean slate', () async {
      when(
        () => repository.verifyCode(contactId: 'email', code: '548412'),
      ).thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadContacts();
      cubit.codeChanged('548412');
      await cubit.verifyCode();
      expect(cubit.state.failure, isNotNull);

      // Editing the code clears the banner, then the retry succeeds.
      cubit.codeChanged('548413');
      expect(cubit.state.failure, isNull);
      when(
        () => repository.verifyCode(contactId: 'email', code: '548413'),
      ).thenAnswer((_) async {});
      await cubit.verifyCode();

      expect(cubit.state.isVerified, isTrue);
    });
  });

  group('new password', () {
    test('an empty submit marks both fields', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.changePassword();

      expect(cubit.state.newPasswordError, 'New password is required.');
      expect(cubit.state.confirmPasswordError, 'Please confirm your password.');
      expect(cubit.state.resetStatus, RequestStatus.initial);
      verifyNoMoreInteractions(repository);
    });

    test('a mismatch marks only the confirmation field', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.newPasswordChanged('housely123');
      cubit.confirmPasswordChanged('housely12');

      await cubit.changePassword();

      expect(cubit.state.newPasswordError, isNull);
      expect(cubit.state.confirmPasswordError, 'Passwords do not match.');
      verifyNoMoreInteractions(repository);
    });

    test('typing in a field clears that field error only', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.changePassword();
      expect(cubit.state.newPasswordError, isNotNull);

      cubit.newPasswordChanged('housely123');

      expect(cubit.state.newPasswordError, isNull);
      expect(cubit.state.confirmPasswordError, isNotNull);
    });

    test('a valid pair submits and reports success', () async {
      when(() => repository.resetPassword(newPassword: 'housely123'))
          .thenAnswer((_) async {});
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.newPasswordChanged('housely123');
      cubit.confirmPasswordChanged('housely123');

      final pending = cubit.changePassword();
      expect(cubit.state.isResetting, isTrue);

      await pending;

      expect(cubit.state.isPasswordChanged, isTrue);
      expect(cubit.state.failure, isNull);
      verify(() => repository.resetPassword(newPassword: 'housely123'))
          .called(1);
    });

    test('a transport failure is a banner, never a red field', () async {
      when(() => repository.resetPassword(newPassword: 'housely123'))
          .thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.newPasswordChanged('housely123');
      cubit.confirmPasswordChanged('housely123');

      await cubit.changePassword();

      expect(cubit.state.resetStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.newPasswordError, isNull);
      expect(cubit.state.confirmPasswordError, isNull);
    });
  });

  group('visibility toggles', () {
    test('both fields start masked and toggle independently', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.obscureNewPassword, isTrue);
      expect(cubit.state.obscureConfirmPassword, isTrue);

      cubit.toggleObscureNewPassword();
      expect(cubit.state.obscureNewPassword, isFalse);
      expect(cubit.state.obscureConfirmPassword, isTrue);

      cubit.toggleObscureConfirmPassword();
      expect(cubit.state.obscureConfirmPassword, isFalse);
    });
  });
}
