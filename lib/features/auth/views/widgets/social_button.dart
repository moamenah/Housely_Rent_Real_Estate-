import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';

/// Circular social auth button (gray100 disc + brand mark), shared by the
/// sign-in and sign-up screens.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.asset,
    required this.onTap,
  });

  /// Visible caption of the provider ('Google', 'Facebook'); also used as the
  /// SVG semantics label.
  final String label;

  /// Path of the provider mark in `assets/icons/`.
  final String asset;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with $label',
      child: Material(
        color: AppColors.gray100,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: 22,
                height: 22,
                semanticsLabel: label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
