/// Base type for every error thrown by the data layer.
///
/// Data sources and repositories throw these; ViewModels (Cubits) never see
/// `DioException` or anything else from the transport layer — they receive a
/// [Failure] instead (see `failure_mapper.dart`).
class AppException implements Exception {
  const AppException([this.message = 'An unexpected error occurred.']);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Device is offline / the request never reached the server.
final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

/// Server answered with a non-2xx status.
final class ServerException extends AppException {
  const ServerException([
    super.message = 'Something went wrong on our side. Please try again.',
  ]);
  const ServerException.fromStatus(int statusCode)
      : super('The server responded with status $statusCode.');
}

/// Payload did not match the expected contract.
final class ParsingException extends AppException {
  const ParsingException([
    super.message = 'We could not read the data returned by the server.',
  ]);
}

/// Requested entity does not exist (404 or missing local record).
final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The item you are looking for is no longer available.',
  ]);
}

/// The backend rejected the submitted credentials.
///
/// Distinct from [ServerException]: the request itself succeeded, the answer
/// is simply "not these credentials" — the UI renders it inline under the
/// password field instead of a generic error screen.
final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([
    super.message = 'The entered password is wrong !',
  ]);
}
