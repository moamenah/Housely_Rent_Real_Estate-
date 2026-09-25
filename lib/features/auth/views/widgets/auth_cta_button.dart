import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Full-width primary button of the auth screens (56px, 18/600 label).
///
/// Loading swaps the label for a spinner; the button keeps its primary color
/// while the request runs, so tapping twice in a row just hits the Cubit's
/// `isLoading` guard again.
class AuthCtaButton extends StatelessWidget {
  const AuthCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Key for the inner [ElevatedButton] (tests target it directly).
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
