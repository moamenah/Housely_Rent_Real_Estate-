import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../viewmodels/properties_cubit.dart';
import '../viewmodels/properties_state.dart';
import 'widgets/property_card.dart';
import 'widgets/property_card_shimmer.dart';

/// Property feed — the app's home branch.
///
/// **View responsibilities only**: render [PropertiesState], forward user
/// intents to [PropertiesCubit]. No async work, no business rules.
class PropertiesView extends StatelessWidget {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => IconButton(
              tooltip: 'Theme: ${mode.name}',
              onPressed: context.read<ThemeCubit>().cycle,
              icon: Icon(switch (mode) {
                ThemeMode.system => Icons.brightness_auto_outlined,
                ThemeMode.light => Icons.light_mode_outlined,
                ThemeMode.dark => Icons.dark_mode_outlined,
              }),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.space4,
              AppDimensions.pagePadding,
              AppDimensions.space16,
            ),
            child: TextField(
              onChanged: context.read<PropertiesCubit>().setQuery,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by name, city or type',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PropertiesCubit, PropertiesState>(
              builder: (context, state) => switch (state.status) {
                RequestStatus.initial ||
                RequestStatus.loading when state.properties.isEmpty =>
                  const _LoadingFeed(),
                RequestStatus.failure when state.properties.isEmpty =>
                  ErrorView(
                    message: state.failure?.message ?? 'Please try again.',
                    onRetry: context.read<PropertiesCubit>().fetchProperties,
                  ),
                _ when state.isEmpty => _EmptyResult(
                    query: state.query,
                    onClear: context.read<PropertiesCubit>().clearQuery,
                  ),
                _ => _PropertyList(state: state),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// First load — skeleton cards matching the real layout.
class _LoadingFeed extends StatelessWidget {
  const _LoadingFeed();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        0,
        AppDimensions.pagePadding,
        AppDimensions.space32,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space16),
      itemBuilder: (_, __) => const PropertyCardShimmer(),
    );
  }
}

/// Loaded feed (optionally filtered by the search field).
class _PropertyList extends StatelessWidget {
  const _PropertyList({required this.state});

  final PropertiesState state;

  @override
  Widget build(BuildContext context) {
    final properties = state.visibleProperties;
    final featured = state.featuredProperties;
    final showFeatured = state.query.trim().isEmpty && featured.isNotEmpty;

    return RefreshIndicator(
      onRefresh: context.read<PropertiesCubit>().refresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          0,
          AppDimensions.pagePadding,
          AppDimensions.space32,
        ),
        children: [
          if (showFeatured) ...[
            Text('Featured', style: context.textTheme.titleLarge),
            const SizedBox(height: AppDimensions.space12),
            SizedBox(
              // Rail height = image (16:10 of a 300dp card) + card copy.
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.space16),
                itemBuilder: (_, index) => SizedBox(
                  width: 300,
                  child: PropertyCard(property: featured[index]),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            Text(
              'All listings (${properties.length})',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.space12),
          ] else if (state.query.trim().isNotEmpty) ...[
            Text(
              '${properties.length} result(s) for "${state.query.trim()}"',
              style: context.textTheme.titleMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.space16),
            itemBuilder: (_, index) => PropertyCard(property: properties[index]),
          ),
        ],
      ),
    );
  }
}

/// Search returned nothing — offer an easy way out.
class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppDimensions.space16),
            Text('No matches found', style: context.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.space8),
            Text(
              query.trim().isEmpty
                  ? 'Nothing to show right now.'
                  : 'We could not find anything for "${query.trim()}".',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space24),
            OutlinedButton(onPressed: onClear, child: const Text('Clear search')),
          ],
        ),
      ),
    );
  }
}
