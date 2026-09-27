import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/error_view.dart';
import '../repositories/home_repository.dart';
import '../viewmodels/popular_cubit.dart';
import '../viewmodels/popular_state.dart';
import 'widgets/popular_tile.dart';

/// Full "Popular for you" list — pushed from the Home screen inside the Home
/// branch, so the tab bar stays visible and the AppBar back arrow returns to
/// the feed. Rows are the same tiles the Home section uses, separated by the
/// hairline dividers the mockup draws between them.
class PopularView extends StatelessWidget {
  const PopularView({super.key, required this.homeRepository});

  final HomeRepository homeRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular')),
      body: BlocProvider(
        create: (_) => PopularCubit(homeRepository: homeRepository)..load(),
        child: const _PopularBody(),
      ),
    );
  }
}

class _PopularBody extends StatelessWidget {
  const _PopularBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularCubit, PopularState>(
      builder: (context, state) {
        if (state.hasFailed) {
          // No fixed-height wrapper: ErrorView shrink-wraps its content.
          return ErrorView(
            message: state.failure?.message ?? 'The list could not be loaded.',
            onRetry: context.read<PopularCubit>().load,
          );
        }

        if (state.isLoading && state.properties.isEmpty) {
          return const _PopularSkeleton();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.space8,
            AppDimensions.pagePadding,
            AppDimensions.space32,
          ),
          itemCount: state.properties.length,
          separatorBuilder: (_, __) =>
              const Divider(height: AppDimensions.space16),
          itemBuilder: (_, index) =>
              PopularTile(property: state.properties[index]),
        );
      },
    );
  }
}

/// Static grey row placeholders for the first frames of a load. Deliberately
/// static: shimmer/indeterminate animations hang `pumpAndSettle`.
class _PopularSkeleton extends StatelessWidget {
  const _PopularSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      child: Column(
        children: [
          for (var i = 0; i < 5; i++) ...[
            Row(
              children: [
                bar(80, 64),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(160, 16),
                      const SizedBox(height: AppDimensions.space8),
                      bar(200, 12),
                      const SizedBox(height: AppDimensions.space8),
                      bar(100, 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
          ],
        ],
      ),
    );
  }
}
