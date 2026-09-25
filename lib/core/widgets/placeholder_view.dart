import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Honest empty/placeholder screen for tabs whose design hasn't landed yet.
///
/// Used by Home and My Booking: the tab exists (the design's 5-tab bar
/// demands it), but there is no mockup to reproduce — so it says so plainly
/// instead of inventing UI the design never specified.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.hourglass_empty_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space48),
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
                  child: Icon(
                    icon,
                    size: AppDimensions.iconXl,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
