import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Back arrow + title + subtitle shared by the recovery screens.
///
/// Same typography as the sign-in / sign-up screens (28/800 headline over a
/// 16/gray400 caption), so the flow reads as one family.
class RecoveryHeader extends StatelessWidget {
  const RecoveryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backLocation,
  });

  final String title;
  final String subtitle;

  /// Where the arrow lands when the screen was reached with `go()` and has
  /// nothing on the stack to pop.
  final String backLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => context.goBackTo(backLocation),
          icon: const Icon(Icons.arrow_back_outlined),
          color: AppColors.gray900,
          iconSize: 26,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        Text(
          title,
          style: context.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          subtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.5,
            color: AppColors.gray400,
          ),
        ),
      ],
    );
  }
}
