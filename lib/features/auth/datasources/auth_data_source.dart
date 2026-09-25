import '../models/user.dart';

/// Contract every auth data source must fulfil.
///
/// The repository depends on this interface only, which is what keeps the
/// offline mock and the future REST/OAuth clients interchangeable (and both
/// testable).
abstract interface class AuthDataSource {
  /// Exchanges credentials for a session.
  ///
  /// Throws [InvalidCredentialsException] when the pair is rejected, or any
  /// other `AppException` subtype (`core/error/exceptions.dart`) on transport
  /// failures — ViewModels map them to a `Failure` with `FailureMapper`.
  Future<User> signIn({required String email, required String password});

  /// Creates the account and returns the freshly signed-in session.
  ///
  /// Same exception contract as [signIn]; business rules (taken email/username,
  /// password policy) belong to the backend and arrive with it.
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  });
}
