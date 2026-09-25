import '../models/property_model.dart';

/// Contract every listing data source must fulfil.
///
/// The repository depends on this interface only, which is what makes the
/// offline fixture and the REST client interchangeable (and both testable).
abstract interface class PropertyDataSource {
  /// All listings.
  Future<List<PropertyModel>> fetchProperties();

  /// Single listing, throws [NotFoundException] when it does not exist.
  Future<PropertyModel> fetchPropertyById(String id);
}
