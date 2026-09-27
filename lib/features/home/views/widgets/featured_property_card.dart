import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/number_extensions.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../properties/models/property.dart';
import 'heart_button.dart';

/// Oversized image card of the "Recommended" rail, rebuilt from the kit's
/// `Banner_1` export: cover photo + bottom scrim, price pill top-right,
/// title and location bottom-left, favourite disc bottom-right.
class FeaturedPropertyCard extends StatelessWidget {
  const FeaturedPropertyCard({super.key, required this.property});

  final Property property;

  /// Rail geometry, measured from the kit's 448×328 export (scaled to the
  /// 234dp card width the mockup shows).
  static const double cardWidth = 234;
  static const double cardHeight = cardWidth * 328 / 448;

  /// Scrim: transparent until 62% of the height, reaching black at ~58%
  /// opacity on the bottom edge (transcribed from `Banner_3`).
  static const List<double> _scrimStops = [0, 0.62, 1];

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return SizedBox(
      width: cardWidth,
      child: AspectRatio(
        aspectRatio: 448 / 328,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(RoutePaths.property(property.id)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PropertyImage(imageUrl: property.imageUrl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.transparent,
                        AppColors.black.withValues(alpha: .58),
                      ],
                      stops: _scrimStops,
                    ),
                  ),
                ),
                // Price pill — 160×52px in the export ≈ 84×27dp, inset 16.
                Positioned(
                  top: AppDimensions.space16,
                  right: AppDimensions.space16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space4,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          property.price.toPrice(),
                          style: theme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(property.pricePeriod.suffix, style: theme.bodySmall),
                      ],
                    ),
                  ),
                ),
                // Title + location, kept clear of the heart disc.
                Positioned(
                  left: AppDimensions.space16,
                  right: AppDimensions.space16 +
                      HeartButton.heartSize +
                      AppDimensions.space8,
                  bottom: AppDimensions.space16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconSm,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: AppDimensions.space4),
                          Expanded(
                            child: Text(
                              property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodySmall
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: AppDimensions.space16,
                  bottom: AppDimensions.space32,
                  child: HeartButton(propertyId: property.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
