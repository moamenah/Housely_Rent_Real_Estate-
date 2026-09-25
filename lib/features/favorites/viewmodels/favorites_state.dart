import 'package:equatable/equatable.dart';

/// State of the favourites ViewModel.
///
/// Stores **ids** only: the source of truth for listing data stays with
/// `PropertiesCubit`, so there is exactly one copy of every listing in memory.
class FavoritesState extends Equatable {
  const FavoritesState({this.propertyIds = const <String>{}});

  final Set<String> propertyIds;

  bool isFavorite(String propertyId) => propertyIds.contains(propertyId);

  int get count => propertyIds.length;

  bool get isEmpty => propertyIds.isEmpty;

  FavoritesState copyWith({Set<String>? propertyIds}) => FavoritesState(
        propertyIds: propertyIds ?? this.propertyIds,
      );

  @override
  List<Object?> get props => [propertyIds];
}
