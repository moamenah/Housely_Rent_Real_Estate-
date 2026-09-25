import 'package:equatable/equatable.dart';

/// UI-facing representation of an error.
///
/// Failures carry a message that is safe to show the user — they are the only
/// error type that crosses from a ViewModel into a View.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  /// Human readable, user-safe message.
  final String message;

  /// Optional machine-readable code (HTTP status, API error code, ...).
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Check your network and try again.',
    super.code,
  });
}

final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong on our side. Please try again.',
    super.code,
  });
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The item you are looking for is no longer available.',
    super.code,
  });
}

final class ParsingFailure extends Failure {
  const ParsingFailure({
    super.message = 'We could not read the data returned by the server.',
    super.code,
  });
}

final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'We could not load the saved data.',
    super.code,
  });
}

/// Sign-in was rejected (or the auth service could not be reached).
///
/// Views distinguish the two cases: a plain `AuthFailure` is shown under the
/// password field, anything else (`NetworkFailure`, `ServerFailure`, …)
/// surfaces as a banner/snackbar.
final class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'We could not sign you in. Please try again.',
    super.code,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Unexpected error. Please try again.',
    super.code,
  });
}
