import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../home/views/widgets/popular_tile.dart';
import '../../properties/viewmodels/properties_cubit.dart';
import '../../properties/viewmodels/properties_state.dart';
import '../viewmodels/favorites_cubit.dart';
import '../viewmodels/favorites_state.dart';

/// Saved listings — the Favorite branch of the shell.
///
/// Reads two ViewModels on purpose: [FavoritesCubit] owns *which* ids are
/// liked, `PropertiesCubit` owns the listing data. The View joins them; neither
/// ViewModel needs to know about the other. Rows are the compact tiles from
/// the Popular list, split by the mockup's hairline dividers.
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        // The mockup draws a back arrow even on the tab: it returns to Home.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goBackTo(RoutePaths.home),
        ),
      ),
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
                // Static placeholder — never an indeterminate spinner.
                return const _FavoritesSkeleton();
              }

              if (favoritesList.isEmpty) {
                return const _EmptyFavorites();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePadding,
                  AppDimensions.space8,
                  AppDimensions.pagePadding,
                  AppDimensions.space32,
                ),
                itemCount: favoritesList.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: AppDimensions.space16),
                itemBuilder: (_, index) =>
                    PopularTile(property: favoritesList[index]),
              );
            },
          );
        },
      ),
    );
  }
}

/// Static grey row placeholders shown while the listing data is still loading.
class _FavoritesSkeleton extends StatelessWidget {
  const _FavoritesSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                bar(80, 64),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(160, 16),
                      const SizedBox(height: AppDimensions.space8),
                      bar(200, 12),
                      const SizedBox(height: AppDimensions.space8),
                      bar(100, 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
          ],
        ],
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
