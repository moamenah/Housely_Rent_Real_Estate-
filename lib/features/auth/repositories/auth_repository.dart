import '../models/user.dart';

/// Contract of the auth **Model** layer as seen by the ViewModel.
///
/// Repositories hide the data source (mock today, REST + OAuth tomorrow) and
/// normalize input, so ViewModels only deal with plain values and `Future`s.
abstract interface class AuthRepository {
  /// Signs the user in and returns the resulting session.
  ///
  /// Throws [AppException] subtypes (`core/error/exceptions.dart`) on failure —
  /// ViewModels map them to a [Failure] with `FailureMapper`.
  Future<User> signIn({required String email, required String password});

  /// Registers the account and returns the resulting session.
  ///
  /// Same exception contract as [signIn].
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
  });
}
