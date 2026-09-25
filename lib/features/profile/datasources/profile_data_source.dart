import '../models/profile.dart';

/// Contract of the profile **Model** layer as seen by the repository.
///
/// The mock reads a fixed demo account; a real data source would resolve the
/// signed-in user from the session and PATCH it to the backend.
abstract interface class ProfileDataSource {
  Future<Profile> getProfile();

  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  });
}
