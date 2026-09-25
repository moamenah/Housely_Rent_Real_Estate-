import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/core/error/exceptions.dart';
import 'package:housely/core/error/failure.dart';
import 'package:housely/features/location/models/place.dart';
import 'package:housely/features/location/repositories/location_repository.dart';
import 'package:housely/features/location/viewmodels/location_picker_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  const pinnedPlace = Place(
    id: 'pinned',
    address: 'Jl. Jend. Sudirman, Gowongan, Kec. Jetis, Kota Yogyakarta',
  );
  const searchedPlace = Place(
    id: 'search:mawar',
    address: 'Gg. Mawar, Gowongan, Kec. Jetis, Kota Yogyakarta',
  );

  late _MockLocationRepository repository;

  LocationPickerCubit buildCubit() =>
      LocationPickerCubit(locationRepository: repository);

  setUp(() {
    repository = _MockLocationRepository();
    when(() => repository.getPinnedPlace())
        .thenAnswer((_) async => pinnedPlace);
    when(() => repository.searchPlace(query: any(named: 'query')))
        .thenAnswer((_) async => searchedPlace);
  });

  group('pinned place', () {
    test('loads the address the pin opens on', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.status, RequestStatus.initial);

      await cubit.loadPinnedPlace();

      expect(cubit.state.status, RequestStatus.success);
      expect(cubit.state.place, pinnedPlace);
      expect(cubit.state.canChoose, isTrue);
      expect(cubit.state.failure, isNull);
    });

    test('a transport failure keeps the card in its failure state',
        () async {
      when(() => repository.getPinnedPlace())
          .thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadPinnedPlace();

      expect(cubit.state.status, RequestStatus.failure);
      expect(cubit.state.place, isNull);
      expect(cubit.state.failure, isA<NetworkFailure>());
      // Nothing to confirm yet — the CTA stays disabled.
      expect(cubit.state.canChoose, isFalse);
    });

    test('the inline retry recovers from a failed load', () async {
      when(() => repository.getPinnedPlace())
          .thenThrow(const NetworkException());
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadPinnedPlace();

      when(() => repository.getPinnedPlace())
          .thenAnswer((_) async => pinnedPlace);
      await cubit.loadPinnedPlace();

      expect(cubit.state.status, RequestStatus.success);
      expect(cubit.state.place, pinnedPlace);
      expect(cubit.state.failure, isNull);
    });
  });

  group('search', () {
    test('resolves the typed query onto the card', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadPinnedPlace();

      cubit.queryChanged('  Mawar  ');
      await cubit.search();

      verify(() => repository.searchPlace(query: 'Mawar')).called(1);
      expect(cubit.state.place, searchedPlace);
      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.status, RequestStatus.success);
    });

    test('an empty query never reaches the backend', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadPinnedPlace();

      cubit.queryChanged('   ');
      await cubit.search();

      verifyNever(() => repository.searchPlace(query: any(named: 'query')));
      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.place, pinnedPlace);
    });

    test('a failed lookup keeps the previous address and banners instead',
        () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadPinnedPlace();

      when(() => repository.searchPlace(query: any(named: 'query')))
          .thenThrow(const NetworkException());
      cubit.queryChanged('Kricak');
      await cubit.search();

      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.place, pinnedPlace);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('typing clears a stale banner', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadPinnedPlace();

      when(() => repository.searchPlace(query: any(named: 'query')))
          .thenThrow(const NetworkException());
      cubit.queryChanged('Kricak');
      await cubit.search();
      expect(cubit.state.failure, isNotNull);

      cubit.queryChanged('Kricak Kidul');
      expect(cubit.state.failure, isNull);
      expect(cubit.state.query, 'Kricak Kidul');
    });
  });
}
