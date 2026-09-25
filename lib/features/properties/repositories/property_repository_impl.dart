import '../../../core/error/exceptions.dart';
import '../datasources/property_data_source.dart';
import '../models/property.dart';
import 'property_repository.dart';

/// Default [PropertyRepository]: maps DTOs → entities and normalises errors
/// to [AppException]s.
class PropertyRepositoryImpl implements PropertyRepository {
  const PropertyRepositoryImpl({required PropertyDataSource dataSource})
      : _dataSource = dataSource;

  final PropertyDataSource _dataSource;

  @override
  Future<List<Property>> getProperties() async {
    final models = await _guard(() => _dataSource.fetchProperties());
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<Property> getPropertyById(String id) async {
    final model = await _guard(() => _dataSource.fetchPropertyById(id));
    return model.toEntity();
  }

  /// Data sources already throw typed exceptions — anything else is a bug or a
  /// transport failure we deliberately don't leak to the ViewModel.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw ServerException(error.toString());
    }
  }
}
