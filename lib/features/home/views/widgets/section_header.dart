import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Section title with a trailing "See all" action — one widget keeps every
/// Home rail's header pixel-identical.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            // The mockup's headings sit a step above the theme's titleLarge.
            style: context.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(
              AppDimensions.space48,
              AppDimensions.space32,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'See all',
            style: context.textTheme.labelMedium
                ?.copyWith(color: context.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
