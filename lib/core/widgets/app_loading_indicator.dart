import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// App-wide indeterminate loader.
///
/// Screens should show this instead of rolling their own
/// `CircularProgressIndicator`.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
          backgroundColor: AppColors.primary100,
        ),
      ),
    );
  }
}
