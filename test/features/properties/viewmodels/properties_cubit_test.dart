import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/features/properties/models/property.dart';
import 'package:housely/features/properties/viewmodels/properties_cubit.dart';
import 'package:housely/features/properties/viewmodels/properties_state.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/properties/repositories/property_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

Property _property(String id, {String title = 'Loft', String location = 'Seattle'}) {
  return Property(
    id: id,
    title: title,
    description: 'description',
    price: 2000,
    location: location,
    bedrooms: 2,
    bathrooms: 1,
    areaSqm: 80,
    imageUrl: 'https://example.com/$id.jpg',
    rating: 4.5,
    reviewsCount: 10,
  );
}

void main() {
  late PropertyRepository repository;

  setUp(() {
    repository = MockPropertyRepository();
  });

  group('PropertiesCubit', () {
    blocTest<PropertiesCubit, PropertiesState>(
      'emits [loading, success] with the fetched listings',
      setUp: () => when(() => repository.getProperties())
          .thenAnswer((_) async => [_property('1'), _property('2')]),
      build: () => PropertiesCubit(repository: repository),
      act: (cubit) => cubit.fetchProperties(),
      expect: () => [
        const PropertiesState(status: RequestStatus.loading),
        PropertiesState(
          status: RequestStatus.success,
          properties: [_property('1'), _property('2')],
        ),
      ],
    );

    blocTest<PropertiesCubit, PropertiesState>(
      'emits [loading, failure] with a mapped failure when the repository throws',
      setUp: () => when(() => repository.getProperties())
          .thenThrow(const NetworkException()),
      build: () => PropertiesCubit(repository: repository),
      act: (cubit) => cubit.fetchProperties(),
      expect: () => const [
        PropertiesState(status: RequestStatus.loading),
        PropertiesState(
          status: RequestStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<PropertiesCubit, PropertiesState>(
      'setQuery exposes only matching listings through visibleProperties',
      setUp: () => when(() => repository.getProperties()).thenAnswer(
        (_) async => [
          _property('1', title: 'Waterfront villa'),
          _property('2', title: 'Garden studio'),
        ],
      ),
      build: () => PropertiesCubit(repository: repository),
      act: (cubit) async {
        await cubit.fetchProperties();
        cubit.setQuery('waterfront');
      },
      verify: (cubit) {
        expect(cubit.state.visibleProperties, hasLength(1));
        expect(cubit.state.visibleProperties.single.id, '1');
        expect(cubit.state.featuredProperties, isEmpty);
      },
    );

    blocTest<PropertiesCubit, PropertiesState>(
      'clearQuery restores the full list',
      setUp: () => when(() => repository.getProperties())
          .thenAnswer((_) async => [_property('1')]),
      build: () => PropertiesCubit(repository: repository),
      act: (cubit) async {
        await cubit.fetchProperties();
        cubit.setQuery('nothing matches');
        cubit.clearQuery();
      },
      verify: (cubit) {
        expect(cubit.state.query, isEmpty);
        expect(cubit.state.visibleProperties, hasLength(1));
      },
    );
  });
}
