import '../models/property.dart';

/// Contract of the listing **Model** layer as seen by a ViewModel.
///
/// Repositories hide the data source (REST today, offline fixture tomorrow)
/// and convert DTOs into domain entities, so ViewModels only ever deal with
/// [Property] and plain `Future`s.
abstract interface class PropertyRepository {
  /// Full listing feed.
  Future<List<Property>> getProperties();

  /// Single listing.
  ///
  /// Throws [AppException] subtypes (`core/error/exceptions.dart`) on failure —
  /// ViewModels map them to a [Failure] with `FailureMapper`.
  Future<Property> getPropertyById(String id);
}
