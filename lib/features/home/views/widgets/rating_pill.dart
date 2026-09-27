import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/number_extensions.dart';

/// Pale-amber star pill ("4.5") shared by the Nearby and Popular tiles.
class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
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
            rating.toRating(),
            style: context.textTheme.labelSmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
