import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/password_recovery_repository.dart';
import 'password_recovery_state.dart';

/// ViewModel of the password-recovery wizard.
///
/// One Cubit backs all four screens (the router provides it in a
/// `ShellRoute`), because the steps share state: the chosen contact feeds the
/// code step, the verified code unlocks the password step.
///
/// Errors keep the auth split: a problem *inside* the form becomes a field
/// error, everything else becomes a snackbar.
class PasswordRecoveryCubit extends Cubit<PasswordRecoveryState> {
  PasswordRecoveryCubit({required PasswordRecoveryRepository repository})
      : _repository = repository,
        super(const PasswordRecoveryState());

  final PasswordRecoveryRepository _repository;

  /// Loads the masked contact options once per flow entry.
  Future<void> loadContacts() async {
    if (state.isLoadingContacts) return;

    emit(state.copyWith(
      contactsStatus: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final contacts = await _repository.getRecoveryContacts();
      // The design shows the email option pre-selected; fall back to whatever
      // the backend offers first so the screen can never start undecided.
      final preferred = contacts.where((c) => c.id == 'email');
      final selectedId = preferred.isNotEmpty
          ? preferred.first.id
          : (contacts.isNotEmpty ? contacts.first.id : null);

      emit(state.copyWith(
        contactsStatus: RequestStatus.success,
        contacts: contacts,
        selectedContactId: selectedId,
        clearFailure: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        contactsStatus: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  void selectContact(String id) {
    if (state.selectedContactId == id) return;
    emit(state.copyWith(selectedContactId: id, clearFailure: true));
  }

  /// Keeps the boxes to digits only and to [PasswordRecoveryState.codeLength].
  void codeChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > PasswordRecoveryState.codeLength
        ? digits.substring(0, PasswordRecoveryState.codeLength)
        : digits;
    emit(state.copyWith(code: code, clearCodeError: true, clearFailure: true));
  }

  Future<void> verifyCode() async {
    if (state.isVerifying) return;

    if (state.code.length != PasswordRecoveryState.codeLength) {
      emit(state.copyWith(
        verifyStatus: RequestStatus.initial,
        codeError:
            'Please enter the ${PasswordRecoveryState.codeLength} digit code.',
        clearFailure: true,
      ));
      return;
    }

    emit(state.copyWith(
      verifyStatus: RequestStatus.loading,
      clearCodeError: true,
      clearFailure: true,
    ));
    try {
      await _repository.verifyCode(
        // Defaults to '' when contacts failed to load — harmless with the
        // mock, and a real backend derives the channel from the session.
        contactId: state.selectedContactId ?? '',
        code: state.code,
      );
      emit(state.copyWith(verifyStatus: RequestStatus.success));
    } catch (error) {
      emit(state.copyWith(
        verifyStatus: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }

  void newPasswordChanged(String value) {
    emit(state.copyWith(
      newPassword: value,
      clearNewPasswordError: true,
      clearFailure: true,
    ));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: value,
      clearConfirmPasswordError: true,
      clearFailure: true,
    ));
  }

  void toggleObscureNewPassword() =>
      emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));

  void toggleObscureConfirmPassword() => emit(
        state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
      );

  Future<void> changePassword() async {
    if (state.isResetting) return;

    final newPasswordError = state.newPassword.isEmpty
        ? 'New password is required.'
        : null;
    final confirmPasswordError = state.confirmPassword.isEmpty
        ? 'Please confirm your password.'
        : (state.confirmPassword != state.newPassword
            ? 'Passwords do not match.'
            : null);

    final validated = state.copyWith(
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
      clearNewPasswordError: newPasswordError == null,
      clearConfirmPasswordError: confirmPasswordError == null,
      clearFailure: true,
    );

    if (newPasswordError != null || confirmPasswordError != null) {
      emit(validated.copyWith(resetStatus: RequestStatus.initial));
      return;
    }

    emit(validated.copyWith(resetStatus: RequestStatus.loading));
    try {
      await _repository.resetPassword(newPassword: validated.newPassword);
      emit(state.copyWith(resetStatus: RequestStatus.success));
    } catch (error) {
      emit(state.copyWith(
        resetStatus: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
