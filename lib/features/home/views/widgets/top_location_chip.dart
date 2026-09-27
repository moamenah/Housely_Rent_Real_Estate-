import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/property_image.dart';
import '../../models/top_location.dart';

/// Destination chip of the "Top Locations" rail — the selected chip fills
/// with the brand colour exactly as the mockup shows.
class TopLocationChip extends StatelessWidget {
  const TopLocationChip({
    super.key,
    required this.location,
    required this.selected,
    required this.onTap,
  });

  final TopLocation location;
  final bool selected;
  final VoidCallback onTap;

  /// Chip height: 40dp thumbnail + 8dp padding on both sides.
  static const double chipHeight = 56;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      side: selected
          ? BorderSide.none
          : const BorderSide(color: AppColors.divider),
    );

    return Material(
      shape: shape,
      color: selected ? AppColors.primary : AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space8,
            AppDimensions.space8,
            AppDimensions.space12,
            AppDimensions.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: PropertyImage(imageUrl: location.imageUrl),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                location.name,
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
