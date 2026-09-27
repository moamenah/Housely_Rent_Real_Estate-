import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/number_extensions.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../properties/models/property.dart';
import 'rating_pill.dart';

/// Compact listing tile of the two-row "Nearby" grid: photo, title, address,
/// price + rating — bordered exactly like the design's cards.
class NearbyTile extends StatelessWidget {
  const NearbyTile({super.key, required this.property});

  final Property property;

  /// Grid geometry: the rail is two rows of these tiles plus a 12dp gutter.
  static const double tileWidth = 258;
  static const double tileHeight = 96;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.property(property.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: SizedBox(
                  width: 80,
                  height: 64,
                  child: PropertyImage(imageUrl: property.imageUrl),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.labelLarge,
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
                            style: theme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Expanded + ellipsis: the rating pill stays pinned
                        // right and the price yields instead of overflowing
                        // the tile on wide (test) fonts.
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: property.price.toPrice(),
                              style: theme.labelLarge,
                              children: [
                                TextSpan(
                                  text: property.pricePeriod.suffix,
                                  style: theme.bodySmall,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        RatingPill(rating: property.rating),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
