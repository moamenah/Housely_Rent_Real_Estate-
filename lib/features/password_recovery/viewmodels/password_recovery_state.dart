import 'package:equatable/equatable.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure.dart';
import '../models/recovery_contact.dart';

/// State of the password-recovery ViewModel.
///
/// The four screens are steps of one flow, so they all read and write this
/// single state: which masked contact was picked, the typed code, the new
/// password and the lifecycle of each async step.
class PasswordRecoveryState extends Equatable {
  /// Digits the design asks for (`Verify your Email`).
  static const int codeLength = 6;

  const PasswordRecoveryState({
    this.contactsStatus = RequestStatus.initial,
    this.contacts = const [],
    this.selectedContactId,
    this.code = '',
    this.codeError,
    this.newPassword = '',
    this.confirmPassword = '',
    this.newPasswordError,
    this.confirmPasswordError,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.verifyStatus = RequestStatus.initial,
    this.resetStatus = RequestStatus.initial,
    this.failure,
  });

  /// Loading of the masked contact options (step 1's only async work).
  final RequestStatus contactsStatus;
  final List<RecoveryContact> contacts;

  /// Destination the code is sent to — pre-set to the email option, as in the
  /// design, so the first screen needs no tap to look right.
  final String? selectedContactId;

  /// Digits typed into the OTP boxes (never longer than [codeLength]).
  final String code;

  /// Rendered under the boxes — a locally detectable problem (too short).
  final String? codeError;

  final String newPassword;
  final String confirmPassword;

  /// Rendered under the respective field.
  final String? newPasswordError;
  final String? confirmPasswordError;

  /// Reveal state of both password fields (hidden by default, as designed).
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  /// Lifecycle of *Verify code* (step 2 → 3).
  final RequestStatus verifyStatus;

  /// Lifecycle of *Change password* (step 3 → 4).
  final RequestStatus resetStatus;

  /// Set only for failures that are not field-scoped, so the View can
  /// snackbar them instead of drawing a red border.
  final Failure? failure;

  bool get isLoadingContacts => contactsStatus == RequestStatus.loading;

  bool get isVerifying => verifyStatus == RequestStatus.loading;

  /// Step 2 finished — the View moves on to the new-password screen.
  bool get isVerified => verifyStatus == RequestStatus.success;

  bool get isResetting => resetStatus == RequestStatus.loading;

  /// Step 3 finished — the View shows the success screen.
  bool get isPasswordChanged => resetStatus == RequestStatus.success;

  bool get isVerifyingFailed => verifyStatus == RequestStatus.failure;

  RecoveryContact? get selectedContact {
    for (final contact in contacts) {
      if (contact.id == selectedContactId) return contact;
    }
    return null;
  }

  PasswordRecoveryState copyWith({
    RequestStatus? contactsStatus,
    List<RecoveryContact>? contacts,
    String? selectedContactId,
    String? code,
    String? newPassword,
    String? confirmPassword,
    RequestStatus? verifyStatus,
    RequestStatus? resetStatus,
    String? codeError,
    String? newPasswordError,
    String? confirmPasswordError,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    Failure? failure,
    bool clearCodeError = false,
    bool clearNewPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool clearFailure = false,
  }) {
    return PasswordRecoveryState(
      contactsStatus: contactsStatus ?? this.contactsStatus,
      contacts: contacts ?? this.contacts,
      selectedContactId: selectedContactId ?? this.selectedContactId,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      resetStatus: resetStatus ?? this.resetStatus,
      codeError: clearCodeError ? null : codeError ?? this.codeError,
      newPasswordError: clearNewPasswordError
          ? null
          : newPasswordError ?? this.newPasswordError,
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : confirmPasswordError ?? this.confirmPasswordError,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        contactsStatus,
        contacts,
        selectedContactId,
        code,
        codeError,
        newPassword,
        confirmPassword,
        newPasswordError,
        confirmPasswordError,
        obscureNewPassword,
        obscureConfirmPassword,
        verifyStatus,
        resetStatus,
        failure,
      ];
}
