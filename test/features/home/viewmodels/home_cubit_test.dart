import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/home/models/home_feed.dart';
import 'package:housely/features/home/models/top_location.dart';
import 'package:housely/features/home/repositories/home_repository.dart';
import 'package:housely/features/home/viewmodels/home_cubit.dart';
import 'package:housely/features/home/viewmodels/home_state.dart';
import 'package:housely/features/properties/models/property.dart';

/// Behavioural fake: returns a two-rail feed unless [failLoad] is armed.
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
      popular: [_property('5', 'Takatea Homestay')],
      topLocations: const [TopLocation(name: 'Bali', imageUrl: 'assets/x.png')],
    );
  }
}

Property _property(String id, String title) => Property(
      id: id,
      title: title,
      description: 'Cozy stay',
      price: 310,
      location: 'Yogyakarta',
      bedrooms: 2,
      bathrooms: 1,
      areaSqm: 90,
      imageUrl: 'assets/images/gallery_1.png',
      rating: 4.8,
      reviewsCount: 126,
    );

void main() {
  late _FakeHomeRepository repository;

  HomeCubit buildCubit() => HomeCubit(homeRepository: repository);

  setUp(() {
    repository = _FakeHomeRepository();
  });

  test('load fills the state with the joined feed', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, RequestStatus.initial);
    expect(cubit.state.feed, isNull);
    // Bali is preselected — the mockup's highlighted chip.
    expect(cubit.state.selectedTopLocation, HomeState.baliIndex);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.feed?.recommended.single.title, 'Ayana Homestay');
    expect(cubit.state.feed?.nearby.single.title, 'Maharani Villa Yogyakarta');
    expect(cubit.state.feed?.popular.single.title, 'Takatea Homestay');
    expect(cubit.state.feed?.topLocations.single.name, 'Bali');
    expect(cubit.state.failure, isNull);
  });

  test('a transport failure becomes a retryable failure state', () async {
    repository.failLoad = true;
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.feed, isNull);
    expect(cubit.state.failure, isA<NetworkFailure>());

    // The View's retry simply re-runs the same call.
    repository.failLoad = false;
    await cubit.load();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.feed, isNotNull);
    expect(cubit.state.failure, isNull);
  });

  test('selecting a destination chip updates only the selection', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    cubit.selectTopLocation(0);

    expect(cubit.state.selectedTopLocation, 0);
    expect(cubit.state.feed, isNotNull);

    // Re-selecting the active chip is a no-op (no redundant emit).
    final before = cubit.state;
    cubit.selectTopLocation(0);
    expect(cubit.state, same(before));
  });
}
