import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/home/models/home_feed.dart';
import 'package:housely/features/home/models/top_location.dart';
import 'package:housely/features/home/repositories/home_repository.dart';
import 'package:housely/features/home/viewmodels/popular_cubit.dart';
import 'package:housely/features/properties/models/property.dart';

/// Behavioural fake: returns a five-row popular list unless [failLoad] is
/// armed.
class _FakeHomeRepository implements HomeRepository {
  bool failLoad = false;

  @override
  Future<HomeFeed> getFeed() async {
    await Future<void>.delayed(Duration.zero);
    if (failLoad) {
      throw const NetworkException();
    }
    return HomeFeed(
      recommended: [_property('1', 'Ayana Homestay')],
      nearby: [_property('3', 'Maharani Villa Yogyakarta')],
      popular: [
        _property('5', 'Takatea Homestay'),
        _property('3', 'Maharani Villa Yogyakarta'),
        _property('2', 'Bali Komang Guest'),
        _property('8', 'Batavia Apartments'),
        _property('9', 'Manhattan Hotel'),
      ],
      topLocations: const [TopLocation(name: 'Bali', imageUrl: 'assets/x.png')],
    );
  }
}

Property _property(String id, String title) => Property(
      id: id,
      title: title,
      description: 'Cozy stay',
      price: 120,
      location: 'Yogyakarta',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 90,
      imageUrl: 'assets/images/gallery_1.png',
      rating: 4.5,
      reviewsCount: 41,
    );

void main() {
  late _FakeHomeRepository repository;

  PopularCubit buildCubit() => PopularCubit(homeRepository: repository);

  setUp(() {
    repository = _FakeHomeRepository();
  });

  test('load fills the state with the popular membership, in order', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.properties, isEmpty);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.properties, hasLength(5));
    expect(
      cubit.state.properties.map((property) => property.title),
      [
        'Takatea Homestay',
        'Maharani Villa Yogyakarta',
        'Bali Komang Guest',
        'Batavia Apartments',
        'Manhattan Hotel',
      ],
    );
    expect(cubit.state.failure, isNull);
  });

  test('a transport failure becomes a retryable failure state', () async {
    repository.failLoad = true;
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.properties, isEmpty);
    expect(cubit.state.failure, isA<NetworkFailure>());

    // The View's retry simply re-runs the same call.
    repository.failLoad = false;
    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.properties, hasLength(5));
    expect(cubit.state.failure, isNull);
  });
}
