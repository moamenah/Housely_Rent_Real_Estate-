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
import 'rating_pill.dart';

/// Full-width row of the "Popular for you" list: photo, title, address,
/// price + rating and the favourite heart — no card chrome, the design runs
/// these rows straight on the background.
class PopularTile extends StatelessWidget {
  const PopularTile({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return InkWell(
      onTap: () => context.push(RoutePaths.property(property.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      // Expanded + ellipsis keeps the rating pill pinned
                      // right without ever overflowing the row.
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
            HeartButton(propertyId: property.id, bare: true),
          ],
        ),
      ),
    );
  }
}
