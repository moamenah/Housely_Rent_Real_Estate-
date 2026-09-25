import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/property_model.dart';
import 'property_data_source.dart';

/// REST implementation of [PropertyDataSource].
///
/// Registered in the DI graph already — point `PropertyDataSource` at this
/// class (see `core/di/injection.dart`) the day the API goes live.
class PropertyRemoteDataSource implements PropertyDataSource {
  const PropertyRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<PropertyModel>> fetchProperties() async {
    final payload = await _apiClient.getJsonList(ApiEndpoints.properties);
    return payload
        .whereType<Map<String, dynamic>>()
        .map(PropertyModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<PropertyModel> fetchPropertyById(String id) async {
    if (id.isEmpty) {
      throw const NotFoundException();
    }
    final json = await _apiClient.getJson(ApiEndpoints.property(id));
    if (json.isEmpty) {
      throw const NotFoundException();
    }
    return PropertyModel.fromJson(json);
  }
}
