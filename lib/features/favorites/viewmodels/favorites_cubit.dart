import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_state.dart';

/// ViewModel behind the heart button and the Favorites tab.
///
/// Session-scoped (provided at the root of `HouselyApp`) so a like survives
/// navigation between branches. Persistence is intentionally left to a future
/// local data source — swap the in-memory `Set` for a repository call here.
class FavoritesCubit extends Cubit<FavoritesState> {
  /// [initialIds] seeds the session (the app opens with the mockup's heart
  /// states already applied); tests default to an empty set.
  FavoritesCubit({Set<String> initialIds = const {}})
      : super(FavoritesState(propertyIds: initialIds));

  void toggle(String propertyId) {
    final next = Set<String>.of(state.propertyIds);
    if (!next.remove(propertyId)) next.add(propertyId);
    emit(state.copyWith(propertyIds: next));
  }

  void add(String propertyId) {
    if (state.isFavorite(propertyId)) return;
    emit(state.copyWith(propertyIds: {...state.propertyIds, propertyId}));
  }

  void remove(String propertyId) {
    if (!state.isFavorite(propertyId)) return;
    final next = Set<String>.of(state.propertyIds)..remove(propertyId);
    emit(state.copyWith(propertyIds: next));
  }

  void clear() => emit(const FavoritesState());
}
