import '../datasources/password_recovery_data_source.dart';
import '../models/recovery_contact.dart';
import 'password_recovery_repository.dart';

class PasswordRecoveryRepositoryImpl implements PasswordRecoveryRepository {
  const PasswordRecoveryRepositoryImpl({
    required PasswordRecoveryDataSource dataSource,
  }) : _dataSource = dataSource;

  final PasswordRecoveryDataSource _dataSource;

  @override
  Future<List<RecoveryContact>> getRecoveryContacts() =>
      _dataSource.getRecoveryContacts();

  @override
  Future<void> verifyCode({
    required String contactId,
    required String code,
  }) {
    // Normalisation lives here (not in the data source): every transport —
    // mock, REST, OAuth — receives the same clean payload.
    return _dataSource.verifyCode(contactId: contactId, code: code.trim());
  }

  @override
  Future<void> resetPassword({required String newPassword}) =>
      _dataSource.resetPassword(newPassword: newPassword);
}
