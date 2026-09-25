import '../datasources/location_data_source.dart';
import '../models/place.dart';
import 'location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({required LocationDataSource dataSource})
      : _dataSource = dataSource;

  final LocationDataSource _dataSource;

  @override
  Future<Place> getPinnedPlace() => _dataSource.getPinnedPlace();

  @override
  Future<Place> searchPlace({required String query}) {
    // Normalisation lives here (not in the data source): every transport —
    // mock, REST, geocoding API — receives the same clean payload.
    return _dataSource.searchPlace(query: query.trim());
  }
}
