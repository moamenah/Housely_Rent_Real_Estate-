import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../properties/viewmodels/properties_cubit.dart';
import '../../properties/viewmodels/properties_state.dart';
import '../../properties/views/widgets/property_card.dart';
import '../viewmodels/favorites_cubit.dart';
import '../viewmodels/favorites_state.dart';

/// Saved listings — the second branch of the shell.
///
/// Reads two ViewModels on purpose: [FavoritesCubit] owns *which* ids are
/// liked, `PropertiesCubit` owns the listing data. The View joins them; neither
/// ViewModel needs to know about the other.
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return const _EmptyFavorites();
          }

          return BlocBuilder<PropertiesCubit, PropertiesState>(
            builder: (context, propertiesState) {
              final favoritesList = propertiesState.properties
                  .where((property) => favorites.isFavorite(property.id))
                  .toList(growable: false);

              if (propertiesState.isLoading && favoritesList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (favoritesList.isEmpty) {
                return const _EmptyFavorites();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePadding,
                  AppDimensions.space16,
                  AppDimensions.pagePadding,
                  AppDimensions.space32,
                ),
                itemCount: favoritesList.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.space16),
                itemBuilder: (_, index) =>
                    PropertyCard(property: favoritesList[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: AppDimensions.iconXl,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            Text('No favorites yet', style: context.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Tap the heart on any listing to keep it here for later.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.explore),
              child: const Text('Browse listings'),
            ),
          ],
        ),
      ),
    );
  }
}
