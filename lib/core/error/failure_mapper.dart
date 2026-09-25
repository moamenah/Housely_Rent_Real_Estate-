import 'exceptions.dart';
import 'failure.dart';

/// Translates data-layer [AppException]s into user-facing [Failure]s.
///
/// ViewModels call this in their `catch` blocks so Views only ever deal with
/// a `Failure`:
/// ```dart
/// } catch (error) {
///   emit(state.copyWith(
///     status: RequestStatus.failure,
///     failure: FailureMapper.map(error),
///   ));
/// }
/// ```
abstract final class FailureMapper {
  FailureMapper._();

  static Failure map(Object error) => switch (error) {
        NetworkException() => NetworkFailure(message: error.message),
        ServerException() => ServerFailure(message: error.message),
        NotFoundException() => NotFoundFailure(message: error.message),
        ParsingException() => ParsingFailure(message: error.message),
        InvalidCredentialsException() => AuthFailure(message: error.message),
        _ => UnknownFailure(message: error.toString()),
      };
}
