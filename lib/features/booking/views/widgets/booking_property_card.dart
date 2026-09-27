import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/number_extensions.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../properties/models/property.dart';

/// Property summary card at the top of the Booking checkout: photo, title,
/// truncated address and the price/rating row from the mockup.
class BookingPropertyCard extends StatelessWidget {
  const BookingPropertyCard({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: SizedBox(
              width: 96,
              height: 96,
              child: PropertyImage(imageUrl: property.imageUrl),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: property.price.toPrice(),
                          style: theme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text: property.pricePeriod.suffix,
                              style: theme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    const Icon(
                      Icons.star_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.warning500,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      property.rating.toRating(),
                      style: theme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
