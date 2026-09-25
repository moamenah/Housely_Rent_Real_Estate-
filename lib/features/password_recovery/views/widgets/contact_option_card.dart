import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/recovery_contact.dart';

/// One selectable destination on the Forgot Password screen.
///
/// Single-choice: the design marks the active card with a purple outline and
/// leaves the rest gray, so the border is the only signal.
class ContactOptionCard extends StatelessWidget {
  const ContactOptionCard({
    super.key,
    required this.contact,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final RecoveryContact contact;

  /// Phone / envelope glyph from the design kit.
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppDimensions.radiusLg));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : AppDimensions.borderWidth,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary100,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: AppDimensions.iconLg,
                  height: AppDimensions.iconLg,
                ),
              ),
              const SizedBox(width: AppDimensions.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      contact.maskedValue,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
