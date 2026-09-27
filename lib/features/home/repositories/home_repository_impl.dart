import '../../properties/models/property.dart';
import '../../properties/repositories/property_repository.dart';
import '../datasources/home_data_source.dart';
import '../models/home_feed.dart';
import 'home_repository.dart';

/// Default [HomeRepository].
///
/// Two sources, one entity: the Home data source owns *which* ids sit in each
/// rail, `PropertyRepository` owns the listings themselves. Ids that no longer
/// resolve are dropped rather than rendered as broken cards, and both
/// underlying calls already fail with typed `AppException`s, so this layer
/// adds no error handling of its own.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required HomeDataSource dataSource,
    required PropertyRepository propertyRepository,
  })  : _dataSource = dataSource,
        _propertyRepository = propertyRepository;

  final HomeDataSource _dataSource;
  final PropertyRepository _propertyRepository;

  @override
  Future<HomeFeed> getFeed() async {
    final plan = await _dataSource.fetchFeedPlan();
    final properties = await _propertyRepository.getProperties();
    final byId = <String, Property>{
      for (final property in properties) property.id: property,
    };

    List<Property> resolve(List<String> ids) => ids
        .map((id) => byId[id])
        .whereType<Property>()
        .toList(growable: false);

    return HomeFeed(
      recommended: resolve(plan.recommendedIds),
      nearby: resolve(plan.nearbyIds),
      popular: resolve(plan.popularIds),
      topLocations: plan.topLocations,
    );
  }
}
