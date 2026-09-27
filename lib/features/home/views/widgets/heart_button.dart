import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../favorites/viewmodels/favorites_cubit.dart';

/// Favourite toggle used by the Home rails.
///
/// Two silhouettes, one ViewModel: the featured card sets the icon on a small
/// white disc (as exported in the kit), the Popular rows show it bare — both
/// drive the session-scoped [FavoritesCubit], so likes stay in sync with the
/// Favorites tab.
class HeartButton extends StatelessWidget {
  const HeartButton({
    super.key,
    required this.propertyId,
    this.bare = false,
  });

  final String propertyId;

  /// `true` → icon only (Popular rows); `false` → white disc behind it.
  final bool bare;

  /// Disc diameter / bare icon size — measured from the kit's card export
  /// (48px on a 448px-wide card ≈ 26dp).
  static const double heartSize = 26;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select(
      (FavoritesCubit cubit) => cubit.state.isFavorite(propertyId),
    );
    final icon = Icon(
      isFavorite ? Icons.favorite : Icons.favorite_border,
      size: bare ? heartSize : 14,
      color: AppColors.error500,
    );

    return Material(
      color: bare ? AppColors.transparent : AppColors.white,
      shape: bare ? null : const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.read<FavoritesCubit>().toggle(propertyId),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: bare
            ? Padding(
                padding: const EdgeInsets.all(AppDimensions.space8),
                child: icon,
              )
            : SizedBox(
                width: heartSize,
                height: heartSize,
                child: Center(child: icon),
              ),
      ),
    );
  }
}
