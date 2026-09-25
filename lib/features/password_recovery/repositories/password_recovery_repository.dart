import '../models/recovery_contact.dart';

/// Use cases of the password-recovery wizard, transport-agnostic.
///
/// Throws `AppException` subtypes (`core/error/exceptions.dart`) on failure —
/// ViewModels map them to a `Failure` with `FailureMapper`.
abstract interface class PasswordRecoveryRepository {
  /// Masked destinations the reset code can be delivered to.
  Future<List<RecoveryContact>> getRecoveryContacts();

  /// Confirms that [code] is the one issued for [contactId].
  Future<void> verifyCode({required String contactId, required String code});

  /// Applies the new password for the pending recovery session.
  Future<void> resetPassword({required String newPassword});
}
