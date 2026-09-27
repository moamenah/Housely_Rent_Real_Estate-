import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/number_extensions.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../favorites/viewmodels/favorites_cubit.dart';
import '../../../favorites/viewmodels/favorites_state.dart';
import '../../models/property.dart';

/// Listing preview used by both the featured rail and the main feed.
class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.property(property.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  // Plain image — a Hero tag here would collide with the same
                  // listing rendered in another shell branch (duplicate tags
                  // in one subtree make Flutter's navigator assert).
                  child: PropertyImage(imageUrl: property.imageUrl),
                ),
                Positioned(
                  top: AppDimensions.space12,
                  left: AppDimensions.space12,
                  child: _TypeBadge(label: property.type.label),
                ),
                Positioned(
                  top: AppDimensions.space8,
                  right: AppDimensions.space8,
                  child: _FavoriteButton(propertyId: property.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.iconSm,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppDimensions.space4),
                      Expanded(
                        child: Text(
                          property.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    // `spaceBetween` + a shrinkable rating group keeps this
                    // row safe on narrow cards: the reviews count yields to an
                    // ellipsis instead of overflowing the card.
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: AppDimensions.iconSm,
                              color: AppColors.warning500,
                            ),
                            const SizedBox(width: AppDimensions.space4),
                            Text(
                              property.rating.toRating(),
                              style: context.textTheme.labelMedium,
                            ),
                            Flexible(
                              child: Text(
                                ' (${property.reviewsCount})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniSpec(
                            icon: Icons.bed_outlined,
                            value: '${property.bedrooms}',
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          _MiniSpec(
                            icon: Icons.bathtub_outlined,
                            value: '${property.bathrooms}',
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Text(
                            property.areaSqm.toArea(),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${property.price.toPrice()}'
                        '${property.pricePeriod.shortSuffix}',
                        style: context.textTheme.titleMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                      Text(
                        property.type.label,
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Heart toggle — forwards the intent to [FavoritesCubit].
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favorites) {
        final isFavorite = favorites.isFavorite(propertyId);
        return Material(
          color: AppColors.white.withValues(alpha: .9),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.read<FavoritesCubit>().toggle(propertyId),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                size: AppDimensions.iconMd,
                color: isFavorite ? AppColors.error500 : AppColors.gray700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniSpec extends StatelessWidget {
  const _MiniSpec({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: AppColors.textMuted),
        const SizedBox(width: AppDimensions.space4),
        Text(value, style: context.textTheme.bodySmall),
      ],
    );
  }
}
