import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// "Yey, your booking success" bottom sheet: the kit's receipt illustration
/// (the pale disc is baked into the export), headline, blurb and the
/// "Explore more" exit.
class BookingSuccessSheet extends StatelessWidget {
  const BookingSuccessSheet({super.key, required this.onExplore});

  /// Pops the sheet, then hands control back to the caller.
  final VoidCallback onExplore;

  /// Presents the sheet over [context].
  static void show(BuildContext context, {required VoidCallback onExplore}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
      ),
      builder: (sheetContext) => BookingSuccessSheet(
        onExplore: () {
          Navigator.of(sheetContext).pop();
          onExplore();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.space8,
          AppDimensions.pagePadding,
          AppDimensions.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
            Image.asset(
              AppAssets.bookingSuccess,
              width: 176,
              height: 176,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppDimensions.space24),
            Text(
              'Yey, your booking success',
              textAlign: TextAlign.center,
              style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space24,
              ),
              child: Text(
                'You have successfully booked a property, '
                'enjoy your property',
                textAlign: TextAlign.center,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightLarge,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXl),
                  ),
                ),
                onPressed: onExplore,
                child: const Text('Explore more'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
