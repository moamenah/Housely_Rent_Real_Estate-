import '../models/place.dart';

/// Contract of the location **Model** layer as seen by the repository.
///
/// Today it resolves addresses offline (mock); swapping in a real
/// geolocation/geocoding provider changes only this side of the feature.
abstract interface class LocationDataSource {
  /// Address the pin rests on when the map opens.
  Future<Place> getPinnedPlace();

  /// Resolves [query] to a concrete address (mock gazetteer + fallback).
  Future<Place> searchPlace({required String query});
}
