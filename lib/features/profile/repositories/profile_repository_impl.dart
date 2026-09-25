import '../datasources/profile_data_source.dart';
import '../models/profile.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileDataSource dataSource})
      : _dataSource = dataSource;

  final ProfileDataSource _dataSource;

  @override
  Future<Profile> getProfile() => _dataSource.getProfile();

  @override
  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  }) {
    // Normalisation lives here (not in the data source): every transport —
    // mock, REST, OAuth — receives the same clean payload.
    return _dataSource.updateProfile(
      name: name.trim(),
      username: username.trim(),
      email: email.trim(),
      dateOfBirth: dateOfBirth,
    );
  }
}
