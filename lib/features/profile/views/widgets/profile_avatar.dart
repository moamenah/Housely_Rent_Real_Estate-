import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Circular account portrait shared by Profile and Edit Profile.
///
/// The design shows a photo, which is not part of this build's assets yet —
/// so the avatar renders the person's initials in brand colors and keeps the
/// camera badge exactly as designed. Dropping a portrait into the data later
/// means only swapping the inner fill of this widget.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.size = 120,
    this.onTap,
  });

  final String name;
  final double size;

  /// When set, the avatar becomes a button (Edit Profile entry point in the
  /// design — tapping the portrait is the affordance the mockup implies).
  final VoidCallback? onTap;

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.30;

    return Semantics(
      button: onTap != null,
      label: onTap != null ? 'Edit profile' : null,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: size * 0.26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: size * 0.02,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: badgeSize * 0.5,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
