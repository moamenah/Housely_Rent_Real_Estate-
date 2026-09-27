import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/extensions/number_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/property_image.dart';
import '../../booking/viewmodels/booking_cubit.dart';
import '../../favorites/viewmodels/favorites_cubit.dart';
import '../../favorites/viewmodels/favorites_state.dart';
import '../../location/views/widgets/map_canvas.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';
import '../viewmodels/property_details_cubit.dart';
import '../viewmodels/property_details_state.dart';
import 'widgets/share_sheet.dart';

/// Listing detail — a screen-scoped ViewModel fed by the route parameter.
class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({
    super.key,
    required this.propertyId,
    required this.propertyRepository,
  });

  final String propertyId;
  final PropertyRepository propertyRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PropertyDetailsCubit(
        repository: propertyRepository,
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

/// The design's Details screen: light AppBar (share + favourite), inset photo
/// pager with dots, a thumbnail strip, then the content sections and the
/// pinned "Rent now" bar.
class _PropertyDetailsContent extends StatefulWidget {
  const _PropertyDetailsContent({required this.property});

  final Property property;

  @override
  State<_PropertyDetailsContent> createState() =>
      _PropertyDetailsContentState();
}

class _PropertyDetailsContentState extends State<_PropertyDetailsContent> {
  late final PageController _galleryController;
  late final TapGestureRecognizer _readMoreRecognizer;
  int _galleryIndex = 0;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    _readMoreRecognizer = TapGestureRecognizer()..onTap = _toggleDescription;
  }

  @override
  void dispose() {
    _galleryController.dispose();
    _readMoreRecognizer.dispose();
    super.dispose();
  }

  void _toggleDescription() => setState(() {
        _descriptionExpanded = !_descriptionExpanded;
      });

  /// Cover photo first, then the kit's interiors — the strip the mockup shows
  /// under the hero.
  List<String> get _gallery => [
        widget.property.imageUrl,
        ...AppAssets.detailsInteriors,
      ];

  /// Shortened copy for the collapsed description. Cut conservatively so the
  /// inline "Read more" link is never pushed past the line limit.
  String get _descriptionPreview {
    const maxChars = 60;
    final text = widget.property.description;
    if (text.length <= maxChars) return '$text ';
    final cut = text.lastIndexOf(' ', maxChars);
    return '${text.substring(0, cut > 20 ? cut : maxChars)}… ';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    final property = widget.property;
    final gallery = _gallery;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Details'),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () => ShareSheet.show(context),
            icon: const Icon(Icons.share),
          ),
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favorites) {
              final isFavorite = favorites.isFavorite(property.id);
              return IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                onPressed: () =>
                    context.read<FavoritesCubit>().toggle(property.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.error500 : AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.space4,
          AppDimensions.pagePadding,
          AppDimensions.space32,
        ),
        children: [
          _GalleryPager(
            gallery: gallery,
            index: _galleryIndex,
            controller: _galleryController,
            onPageChanged: (index) => setState(() => _galleryIndex = index),
          ),
          const SizedBox(height: AppDimensions.space12),
          _ThumbnailStrip(
            gallery: gallery,
            selectedIndex: _galleryIndex,
            onJump: (index) => _galleryController.animateToPage(
              index,
              duration: AppDimensions.animationNormal,
              curve: Curves.easeOut,
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: property.price.toPrice(),
                      style: theme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: property.pricePeriod.suffix,
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: AppDimensions.iconMd,
                color: AppColors.gray400,
              ),
              const SizedBox(width: AppDimensions.space4),
              Expanded(
                child: Text(
                  property.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyLarge?.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),
          Text(
            'Property Details',
            style:
                theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.space16),
          _SpecGrid(property: property),
          const SizedBox(height: AppDimensions.space24),
          Text(
            'Description',
            style:
                theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text.rich(
            TextSpan(
              text: _descriptionExpanded
                  ? '${property.description} '
                  : _descriptionPreview,
              style: theme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: _descriptionExpanded ? 'Read less' : 'Read more',
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: _readMoreRecognizer,
                ),
              ],
            ),
            maxLines: _descriptionExpanded ? null : 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.space24),
          Text(
            'Agent',
            style:
                theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.space12),
          const _AgentSection(),
          const SizedBox(height: AppDimensions.space24),
          Text(
            'Location & Public Facilities',
            style: theme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          const _FacilitiesRail(),
          const SizedBox(height: AppDimensions.space12),
          const _MapPreview(),
          const SizedBox(height: AppDimensions.space24),
          _ReviewsHeader(reviewsCount: property.reviewsCount),
          const SizedBox(height: AppDimensions.space12),
          const _ReviewsRail(),
        ],
      ),
      bottomNavigationBar: _RentBar(
        onRent: () {
          // The checkout session follows the listing being rented, then
          // the Booking screen is pushed above the shell.
          context.read<BookingCubit>().startBooking(property.id);
          context.push(RoutePaths.booking);
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Gallery
// -----------------------------------------------------------------------------

/// Inset cover-photo pager with the mockup's page dots.
class _GalleryPager extends StatelessWidget {
  const _GalleryPager({
    required this.gallery,
    required this.index,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String> gallery;
  final int index;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedia),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: gallery.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, page) =>
                  PropertyImage(imageUrl: gallery[page]),
            ),
            Positioned(
              bottom: AppDimensions.space12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < gallery.length; i++)
                    AnimatedContainer(
                      duration: AppDimensions.animationFast,
                      width: AppDimensions.space8,
                      height: AppDimensions.space8,
                      margin: EdgeInsets.only(
                        right: i == gallery.length - 1
                            ? 0
                            : AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == index
                            ? AppColors.primary
                            : AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail strip under the hero — tap to jump the pager; the active thumb
/// gets the primary outline.
class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.gallery,
    required this.selectedIndex,
    required this.onJump,
  });

  final List<String> gallery;
  final int selectedIndex;
  final ValueChanged<int> onJump;

  static const double _width = 78;
  static const double _height = 66;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.space12),
        itemBuilder: (_, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onJump(index),
            child: Container(
              width: _width,
              height: _height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLg),
                border: selected
                    ? Border.all(
                        color: AppColors.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: PropertyImage(imageUrl: gallery[index]),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Facts
// -----------------------------------------------------------------------------

/// Two rows of three facts — icons on the first row, plain values below,
/// exactly the mockup's grid.
class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _specRow([
          _SpecCell(
            label: 'Bedrooms',
            value: '${property.bedrooms}',
            icon: Icons.bed_outlined,
          ),
          _SpecCell(
            label: 'Bathroom',
            value: '${property.bathrooms}',
            icon: Icons.bathtub_outlined,
          ),
          _SpecCell(
            label: 'Area',
            value: property.areaSqm.toSqft(),
            icon: Icons.crop_square_rounded,
          ),
        ]),
        const SizedBox(height: AppDimensions.space16),
        _specRow(const [
          _SpecCell(label: 'Build', value: '2020'),
          _SpecCell(label: 'Parking', value: '1 Indoor'),
          _SpecCell(label: 'Status', value: 'For Rent'),
        ]),
      ],
    );
  }

  static Widget _specRow(List<_SpecCell> cells) {
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.space12),
          Expanded(child: cells[i]),
        ],
      ],
    );
  }
}

class _SpecCell extends StatelessWidget {
  const _SpecCell({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.bodySmall?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: AppDimensions.space4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppDimensions.iconSm,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.space4),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Description
// -----------------------------------------------------------------------------

class _AgentSection extends StatelessWidget {
  const _AgentSection();

  static const String _name = 'Esther Howard';
  static const String _role = 'Real Estate Agent';

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(AppAssets.agentAvatar, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              Text(
                _role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall?.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        _AgentCircleButton(
          icon: Icons.phone,
          tooltip: 'Call agent',
          onTap: () => context.showSnack(
            "Calling the agent isn't available in this build yet.",
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        _AgentCircleButton(
          icon: Icons.chat_bubble_outline,
          tooltip: 'Message agent',
          onTap: () => context.showSnack(
            "Messaging the agent isn't available in this build yet.",
          ),
        ),
      ],
    );
  }
}

class _AgentCircleButton extends StatelessWidget {
  const _AgentCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(
            icon,
            size: AppDimensions.iconLg,
            color: AppColors.primary,
            semanticLabel: tooltip,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Location & facilities
// -----------------------------------------------------------------------------

class _Facility {
  const _Facility(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _FacilitiesRail extends StatelessWidget {
  const _FacilitiesRail();

  static const List<_Facility> _facilities = [
    _Facility(Icons.local_hospital, 'Hospital'),
    _Facility(Icons.local_gas_station, 'Gas stations'),
    _Facility(Icons.shopping_bag, 'Mall'),
    _Facility(Icons.account_balance, 'Mosque'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _facilities.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.space12),
        itemBuilder: (_, index) {
          final facility = _facilities[index];
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  facility.icon,
                  size: AppDimensions.iconSm,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.space4),
                Text(
                  facility.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Static street map with the orange pin — the location picker's canvas,
/// reused so both maps render from one painter.
class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: SizedBox(
        height: 146,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: MapCanvas()),
            const Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.place,
                  size: 44,
                  color: AppColors.mapMarker,
                  shadows: [
                    Shadow(color: AppColors.black26, blurRadius: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Reviews
// -----------------------------------------------------------------------------

class _Review {
  const _Review(this.author, this.avatar, this.text);

  final String author;
  final String avatar;
  final String text;
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({required this.reviewsCount});

  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Reviews $reviewsCount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () => context.showSnack(
            "Full reviews aren't available in this build yet.",
          ),
          child: Text(
            'See all',
            style: theme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewsRail extends StatelessWidget {
  const _ReviewsRail();

  static const List<_Review> _reviews = [
    _Review(
      'Theresa Webb',
      AppAssets.reviewerAvatar,
      'Lorem Ipsum is simply dummy text of the printing and typesetting '
      'industry. 1500s,',
    ),
    _Review(
      'Arlene McCoy',
      AppAssets.agentAvatar,
      'Contrary to popular belief, Lorem Ipsum is not just random text. It '
      'has roots in a piece of classical literature.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _reviews.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.space12),
        itemBuilder: (_, index) => _ReviewCard(review: _reviews[index]),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _Review review;

  static const double _width = 268;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Container(
      width: _width,
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(review.avatar, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    const _StarRating(),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  review.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Four and a half stars, warning amber — matches the review rows.
class _StarRating extends StatelessWidget {
  const _StarRating();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.warning500,
        ),
        Icon(
          Icons.star_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.warning500,
        ),
        Icon(
          Icons.star_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.warning500,
        ),
        Icon(
          Icons.star_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.warning500,
        ),
        Icon(
          Icons.star_half_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.warning500,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Pinned CTA
// -----------------------------------------------------------------------------

class _RentBar extends StatelessWidget {
  const _RentBar({required this.onRent});

  final VoidCallback onRent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.space12,
          AppDimensions.pagePadding,
          AppDimensions.space12,
        ),
        child: ElevatedButton(
          onPressed: onRent,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              AppDimensions.buttonHeightLarge,
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: const Text('Rent now'),
        ),
      ),
    );
  }
}
