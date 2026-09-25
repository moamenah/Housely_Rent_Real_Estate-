import '../models/place.dart';

/// Use cases of the location step, transport-agnostic.
///
/// Throws `AppException` subtypes (`core/error/exceptions.dart`) on failure —
/// ViewModels map them to a `Failure` with `FailureMapper`.
abstract interface class LocationRepository {
  /// Address the pin rests on when the map opens.
  Future<Place> getPinnedPlace();

  /// Resolves a typed query to a concrete address.
  Future<Place> searchPlace({required String query});
}
