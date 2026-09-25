import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/features/favorites/viewmodels/favorites_cubit.dart';
import 'package:housely/features/favorites/viewmodels/favorites_state.dart';

void main() {
  group('FavoritesCubit', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'starts empty',
      build: FavoritesCubit.new,
      verify: (cubit) => expect(cubit.state.propertyIds, isEmpty),
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggle adds an id that is not saved yet',
      build: FavoritesCubit.new,
      act: (cubit) => cubit.toggle('42'),
      expect: () => const [FavoritesState(propertyIds: {'42'})],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggle removes an already saved id',
      build: FavoritesCubit.new,
      act: (cubit) => cubit
        ..add('1')
        ..add('2')
        ..toggle('1'),
      expect: () => const [
        FavoritesState(propertyIds: {'1'}),
        FavoritesState(propertyIds: {'1', '2'}),
        FavoritesState(propertyIds: {'2'}),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'remove is a no-op for unknown ids',
      build: FavoritesCubit.new,
      act: (cubit) => cubit.remove('missing'),
      expect: () => const <FavoritesState>[],
    );
  });
}
