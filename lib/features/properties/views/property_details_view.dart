import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/extensions/number_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../favorites/viewmodels/favorites_cubit.dart';
import '../../favorites/viewmodels/favorites_state.dart';
import '../models/property.dart';
import '../viewmodels/property_details_cubit.dart';
import '../viewmodels/property_details_state.dart';

/// Listing detail — a screen-scoped ViewModel fed by the route parameter.
class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyDetailsCubit(
        repository: context.read(),
      )..load(propertyId),
      child: _PropertyDetailsBody(propertyId: propertyId),
    );
  }
}

class _PropertyDetailsBody extends StatelessWidget {
  const _PropertyDetailsBody({required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
      builder: (context, state) {
        if (state.isLoading && state.property == null) {
          return const Scaffold(
            body: AppLoadingIndicator(),
          );
        }

        if (state.hasError && state.property == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: state.failure?.message ?? 'Please try again.',
              onRetry: () =>
                  context.read<PropertyDetailsCubit>().load(propertyId),
            ),
          );
        }

        final property = state.property;
        if (property == null) return const SizedBox.shrink();

        return _PropertyDetailsContent(property: property);
      },
    );
  }
}

class _PropertyDetailsContent extends StatelessWidget {
  const _PropertyDetailsContent({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.dark,
            foregroundColor: AppColors.white,
            actions: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favorites) {
                  final isFavorite = favorites.isFavorite(property.id);
                  return IconButton(
                    tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(property.id),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.error500 : AppColors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: AppDimensions.space8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'property-image-${property.id}',
                child: _PropertyImage(imageUrl: property.imageUrl),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      _RatingBadge(property: property),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.iconMd,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppDimensions.space4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  _SpecRow(property: property),
                  const SizedBox(height: AppDimensions.space24),
                  Text('About this place', style: context.textTheme.titleLarge),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    property.description,
                    style: context.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  Wrap(
                    spacing: AppDimensions.space8,
                    runSpacing: AppDimensions.space8,
                    children: [
                      Chip(label: Text(property.type.label)),
                      Chip(label: Text(property.areaSqm.toArea())),
                      Chip(
                        label: Text(
                          '${property.reviewsCount} reviews',
                        ),
                      ),
                    ],
                  ),
                  // Space for the pinned bottom bar.
                  const SizedBox(height: AppDimensions.space64),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PriceBar(property: property),
    );
  }
}

/// Pinned CTA strip: price on the left, action on the right.
class _PriceBar extends StatelessWidget {
  const _PriceBar({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.space16,
          AppDimensions.pagePadding,
          AppDimensions.space16,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${property.price.toPrice()}/mo',
                  style: context.textTheme.titleLarge
                      ?.copyWith(color: AppColors.primary),
                ),
                Text(
                  'excl. utilities',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.space24),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.showSnack(
                  'Viewing request sent — we will get back to you.',
                ),
                child: const Text('Book a viewing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Spec(
            icon: Icons.bed_outlined,
            label: 'Beds',
            value: '${property.bedrooms}',
          ),
          _Spec(
            icon: Icons.bathtub_outlined,
            label: 'Baths',
            value: '${property.bathrooms}',
          ),
          _Spec(
            icon: Icons.crop_square_rounded,
            label: 'Area',
            value: property.areaSqm.toArea(),
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconLg, color: AppColors.primary),
        const SizedBox(height: AppDimensions.space4),
        Text(value, style: context.textTheme.labelMedium),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.warning200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: AppDimensions.iconSm,
            color: AppColors.warning500,
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(property.rating.toRating(), style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Image with graceful placeholder/error fallbacks.
class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => const ColoredBox(color: AppColors.gray100),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: AppColors.gray100,
        child: Icon(
          Icons.home_work_outlined,
          size: 48,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
