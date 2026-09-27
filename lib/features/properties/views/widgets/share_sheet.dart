import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// "Share to" bottom sheet from the Details mockup: drag handle, title and a
/// 3×2 grid of social targets (two rows of three).
class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key, required this.onShare});

  /// Closes the sheet and reports the tapped target's label.
  final ValueChanged<String> onShare;

  /// Order mirrors the mockup: Facebook, Instagram, Twitter / Whatsapp,
  /// Linkedin, Pinterest.
  static const List<_ShareTarget> _targets = [
    _ShareTarget('Facebook', AppAssets.shareFacebook),
    _ShareTarget('Instagram', AppAssets.shareInsta),
    _ShareTarget('Twitter', AppAssets.shareTwitter),
    _ShareTarget('Whatsapp', AppAssets.shareWhatsapp),
    _ShareTarget('Linkedin', AppAssets.shareLinkedin),
    _ShareTarget('Pinterest', AppAssets.sharePinterest),
  ];

  /// Presents the sheet over [context]; a target tap closes it and shows the
  /// honest "not in this build" notice through the caller's context.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
      ),
      builder: (sheetContext) => ShareSheet(
        onShare: (label) {
          Navigator.of(sheetContext).pop();
          context.showSnack(
            "Sharing via $label isn't available in this build yet.",
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Share to',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: AppDimensions.space20),
              Row(
                children: [
                  for (var col = 0; col < 3; col++) ...[
                    if (col > 0) const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: _ShareTile(
                        target: _targets[row * 3 + col],
                        onTap: () => onShare(_targets[row * 3 + col].label),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.target, required this.onTap});

  final _ShareTarget target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              target.icon,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              target.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareTarget {
  const _ShareTarget(this.label, this.icon);

  final String label;
  final String icon;
}
