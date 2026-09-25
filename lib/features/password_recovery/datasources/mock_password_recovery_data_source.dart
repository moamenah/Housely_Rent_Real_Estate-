import '../models/recovery_contact.dart';
import 'password_recovery_data_source.dart';

/// Offline stand-in for the recovery endpoints.
///
/// Demo rules: the contact list is fixed (straight from the design) and both
/// write calls succeed after [latency] — code issuance, code checking and
/// password policy all belong to the real API when it ships.
class MockPasswordRecoveryDataSource implements PasswordRecoveryDataSource {
  const MockPasswordRecoveryDataSource({
    this.latency = const Duration(milliseconds: 600),
  });

  final Duration latency;

  @override
  Future<List<RecoveryContact>> getRecoveryContacts() async {
    await Future<void>.delayed(latency);
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
    await Future<void>.delayed(latency);
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    await Future<void>.delayed(latency);
  }
}
