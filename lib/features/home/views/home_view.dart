import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../../properties/models/property.dart';
import '../models/top_location.dart';
import '../repositories/home_repository.dart';
import '../viewmodels/home_cubit.dart';
import '../viewmodels/home_state.dart';
import 'widgets/featured_property_card.dart';
import 'widgets/nearby_tile.dart';
import 'widgets/popular_tile.dart';
import 'widgets/section_header.dart';
import 'widgets/top_location_chip.dart';

/// Home tab — the design's landing feed.
///
/// **View responsibilities only**: render [HomeState], forward user intents to
/// [HomeCubit]. The static chrome (location header, search, promo banner)
/// sits above the state-driven rails; likes are delegated to the
/// session-scoped FavoritesCubit through the shared `HeartButton`.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.homeRepository});

  final HomeRepository homeRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => HomeCubit(homeRepository: homeRepository)..load(),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => ListView(
              padding: const EdgeInsets.only(
                top: AppDimensions.space16,
                bottom: AppDimensions.space32,
              ),
              children: [
                _inset(const _HomeHeader()),
                const SizedBox(height: AppDimensions.space32),
                _inset(const _HomeSearch()),
                const SizedBox(height: AppDimensions.space24),
                _inset(const _PromoBanner()),
                const SizedBox(height: AppDimensions.space32),
                ..._buildSections(context, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Page-gutter inset. Rails opt out of the right edge so they bleed off the
  /// screen exactly like the mockup does (recommended card #2, the grid's
  /// second column, the fourth destination chip).
  static Widget _inset(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
        ),
        child: child,
      );

  List<Widget> _buildSections(BuildContext context, HomeState state) {
    if (state.hasFailed) {
      // No fixed-height wrapper: ErrorView shrink-wraps its content, so it
      // can never overflow a hard-coded box.
      return [
        ErrorView(
          message: state.failure?.message ?? 'The feed could not be loaded.',
          onRetry: context.read<HomeCubit>().load,
        ),
      ];
    }

    final feed = state.feed;
    if (feed == null) {
      // First frame before the load tick — static skeleton, never shimmer:
      // indeterminate animations hang `pumpAndSettle` in widget tests.
      return const [_FeedSkeleton()];
    }

    final cubit = context.read<HomeCubit>();
    void goToExplore() => context.go(RoutePaths.explore);

    return [
      _inset(SectionHeader(title: 'Recommended', onSeeAll: goToExplore)),
      const SizedBox(height: AppDimensions.space12),
      _RecommendedRail(properties: feed.recommended),
      const SizedBox(height: AppDimensions.space32),
      _inset(SectionHeader(title: 'Nearby', onSeeAll: goToExplore)),
      const SizedBox(height: AppDimensions.space12),
      _NearbyRail(properties: feed.nearby),
      const SizedBox(height: AppDimensions.space32),
      _inset(
        SectionHeader(
          title: 'Top Locations',
          onSeeAll: () => context.showSnack(
            "Top locations aren't available in this build yet.",
          ),
        ),
      ),
      const SizedBox(height: AppDimensions.space12),
      _LocationRail(
        locations: feed.topLocations,
        selectedIndex: state.selectedTopLocation,
        onSelect: cubit.selectTopLocation,
      ),
      const SizedBox(height: AppDimensions.space32),
      _inset(
        SectionHeader(
          title: 'Popular for you',
          onSeeAll: () => context.push(RoutePaths.popular),
        ),
      ),
      const SizedBox(height: AppDimensions.space12),
      _inset(
        Column(
          // Home shows the first three rows like the mockup; the pushed
          // "Popular" screen renders the full list.
          children: [
            for (var i = 0; i < feed.popular.take(3).length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.space16),
              PopularTile(property: feed.popular[i]),
            ],
          ],
        ),
      ),
    ];
  }
}

// -----------------------------------------------------------------------------
// Static chrome
// -----------------------------------------------------------------------------

/// Status row: location selector on the left, bell + chat circles right.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.showSnack(
                  "Changing your location isn't available in this build yet.",
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Location',
                      style: theme.bodyMedium?.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: AppDimensions.iconMd,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: AppDimensions.iconLg,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Flexible(
                    child: Text(
                      'Yogyakarta, Ind',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _CircleButton(
          icon: Icons.notifications_none,
          badge: true,
          onTap: () => context.push(RoutePaths.notifications),
        ),
        const SizedBox(width: AppDimensions.space12),
        _CircleButton(
          icon: Icons.chat_bubble_outline,
          chatGlyph: true,
          onTap: () => context.showSnack(
            "Messages aren't available in this build yet.",
          ),
        ),
      ],
    );
  }
}

/// 44dp outlined circle (the mockup's 60px rings at 1.44 scale ≈ 42dp, sized
/// up to 44 for tap comfort).
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.chatGlyph = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Red unread dot on the bell.
  final bool badge;

  /// Draw the three message dots inside the bubble.
  final bool chatGlyph;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: AppDimensions.iconLg, color: AppColors.textPrimary),
              if (badge)
                const Positioned(
                  top: AppDimensions.space8 + 2,
                  right: AppDimensions.space8 + 2,
                  child: _Dot(size: AppDimensions.space8),
                ),
              if (chatGlyph)
                const Positioned(
                  // Optical centring inside `chat_bubble_outline`'s body.
                  left: 5.5,
                  top: 8.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Dot(size: 3),
                      SizedBox(width: 2),
                      _Dot(size: 3),
                      SizedBox(width: 2),
                      _Dot(size: 3),
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

class _Dot extends StatelessWidget {
  const _Dot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.error500,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Search field → Explore (the mockup's field is the entry to the full feed).
class _HomeSearch extends StatelessWidget {
  const _HomeSearch();

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return InkWell(
      onTap: () => context.go(RoutePaths.explore),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        height: AppDimensions.inputHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: AppDimensions.iconLg,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                'Search Property',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyLarge?.copyWith(color: AppColors.gray400),
              ),
            ),
            const Icon(
              Icons.tune,
              size: AppDimensions.iconLg,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// `Banner_2` cashback promo — full-bleed inside the page gutter.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('home_promo_banner'),
      onTap: () => context.showSnack(
        "This offer isn't available in this build yet.",
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedia),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedia),
        child: AspectRatio(
          aspectRatio: 654 / 220,
          child: Image.asset(AppAssets.bannerPromo, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// State-driven rails
// -----------------------------------------------------------------------------

/// Horizontal rail of oversized featured cards ("Recommended").
class _RecommendedRail extends StatelessWidget {
  const _RecommendedRail({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.pagePadding),
      child: SizedBox(
        height: FeaturedPropertyCard.cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppDimensions.space24),
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppDimensions.space24),
          itemCount: properties.length,
          itemBuilder: (_, index) =>
              FeaturedPropertyCard(property: properties[index]),
        ),
      ),
    );
  }
}

/// Two-row horizontal grid of compact tiles ("Nearby") — the right-hand
/// column peeks off-screen like the mockup.
class _NearbyRail extends StatelessWidget {
  const _NearbyRail({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.pagePadding),
      child: SizedBox(
        height: NearbyTile.tileHeight * 2 + AppDimensions.space12,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppDimensions.space24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: NearbyTile.tileWidth,
            mainAxisSpacing: AppDimensions.space16,
            crossAxisSpacing: AppDimensions.space12,
          ),
          itemCount: properties.length,
          itemBuilder: (_, index) => NearbyTile(property: properties[index]),
        ),
      ),
    );
  }
}

/// Destination chips ("Top Locations") — Bali preselected per the mockup.
class _LocationRail extends StatelessWidget {
  const _LocationRail({
    required this.locations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TopLocation> locations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.pagePadding),
      child: SizedBox(
        height: TopLocationChip.chipHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppDimensions.space24),
          separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.space8),
          itemCount: locations.length,
          itemBuilder: (_, index) => TopLocationChip(
            location: locations[index],
            selected: index == selectedIndex,
            onTap: () => onSelect(index),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Loading skeleton
// -----------------------------------------------------------------------------

/// Static grey skeleton for the first frames of a load. Deliberately static:
/// shimmer/indeterminate spinners hang `pumpAndSettle` in widget tests.
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height, {double radius = 8}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(160, 26, radius: AppDimensions.radiusMd),
          const SizedBox(height: AppDimensions.space12),
          SizedBox(
            height: FeaturedPropertyCard.cardHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                bar(
                  FeaturedPropertyCard.cardWidth,
                  FeaturedPropertyCard.cardHeight,
                  radius: AppDimensions.radiusMedia,
                ),
                const SizedBox(width: AppDimensions.space24),
                bar(
                  FeaturedPropertyCard.cardWidth,
                  FeaturedPropertyCard.cardHeight,
                  radius: AppDimensions.radiusMedia,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          bar(120, 26, radius: AppDimensions.radiusMd),
          const SizedBox(height: AppDimensions.space12),
          bar(double.infinity, 96, radius: AppDimensions.radiusXl),
        ],
      ),
    );
  }
}
