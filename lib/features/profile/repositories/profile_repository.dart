import '../models/profile.dart';

/// Use cases of the account hub, transport-agnostic.
///
/// Throws `AppException` subtypes (`core/error/exceptions.dart`) on failure —
/// ViewModels map them to a `Failure` with `FailureMapper`.
abstract interface class ProfileRepository {
  /// The account shown on Profile / Edit Profile.
  Future<Profile> getProfile();

  /// Persists the edited account and returns the stored result.
  Future<Profile> updateProfile({
    required String name,
    required String username,
    required String email,
    required DateTime? dateOfBirth,
  });
}
