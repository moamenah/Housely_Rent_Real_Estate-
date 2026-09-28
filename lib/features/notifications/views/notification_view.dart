import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';
import '../viewmodels/notification_cubit.dart';
import '../viewmodels/notification_state.dart';

/// Notification inbox — day-grouped rich rows and the "No notification yet"
/// empty state.
///
/// **View responsibilities only**: render [NotificationState], forward the
/// retry intent to [NotificationCubit]. Pushed full-screen (above the shell)
/// from the Home bell and the Profile menu, so the mockup's back arrow pops
/// to whichever entry point was used.
class NotificationView extends StatelessWidget {
  const NotificationView({super.key, required this.notificationRepository});

  /// Injected by the router so the View never touches the service locator.
  final NotificationRepository notificationRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationCubit(notificationRepository: notificationRepository)
            ..load(),
      child: const _NotificationBody(),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mockup export samples #FCFCFD at the top *and* bottom of the page.
      backgroundColor: AppColors.grayNeutral25,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NotificationHeader(),
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state.hasFailed) {
                    // No fixed-height wrapper: ErrorView shrink-wraps.
                    return ErrorView(
                      message: state.failure?.message ??
                          'Your notifications could not be loaded.',
                      onRetry: context.read<NotificationCubit>().load,
                    );
                  }

                  if (!state.isLoaded) {
                    // First frames of the load — static skeleton, never an
                    // indeterminate spinner (it would hang `pumpAndSettle`).
                    return const _NotificationsSkeleton();
                  }

                  if (state.isEmpty) {
                    return const _EmptyNotifications();
                  }

                  return _NotificationList(sections: state.sections);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Static chrome
// -----------------------------------------------------------------------------
// Deliberately a hand-built row instead of `AppBar`: the mockup centres the
// title on the *screen*, which a leading button would shift off-centre.
class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        // Mockup: back-arrow glyph centre at 36.7dp (icon box = 12 + 24).
        AppDimensions.space12,
        AppDimensions.space4,
        AppDimensions.space12,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('notification_back_button'),
            onPressed: () => context.goBackTo(RoutePaths.home),
            icon: const Icon(Icons.arrow_back_outlined),
            color: AppColors.gray900,
            iconSize: 26,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notification',
                style: context.textTheme.titleLarge?.copyWith(
                  // Mockup title ink is 92.1dp wide → 18pt bold.
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Day-grouped rows
// -----------------------------------------------------------------------------

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.sections});

  final List<NotificationSection> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        // 25dp gutter (see pagePaddingWide): circle left edge at 25, text
        // column at 75, hairline right end at 365 — all three measured.
        AppDimensions.pagePaddingWide,
        AppDimensions.space24,
        AppDimensions.pagePaddingWide,
        AppDimensions.space32,
      ),
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          // Mockup: 28dp from the previous section's hairline to the next
          // section heading (Yesterday ink lands at 313.8).
          if (index > 0)
            const SizedBox(
              height: AppDimensions.space24 + AppDimensions.space4,
            ),
          Text(
            sections[index].title,
            style: context.textTheme.titleLarge?.copyWith(
              // "Today" ink 47.8 / "Yesterday" ink 79.7 → 18pt bold.
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          // Mockup: 10dp from the header baseline box to the first row
          // (circle top 162.1 with the list top pad at 24).
          const SizedBox(height: AppDimensions.space8 + AppDimensions.space2),
          for (final item in sections[index].items)
            _NotificationRow(item: item),
        ],
      ],
    );
  }
}

/// One inbox row: leading glyph/photo · rich message · hairline underneath.
///
/// The divider spans only the text column (it starts where the message does
/// and runs to the page gutter), exactly like the mockup.
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  static const double _leadingSize = AppDimensions.notificationLeading;

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Vertical rhythm measured off the mockup: pad 6 + two 13.4/1.4 lines
      // (37.5) + 12 gap + hairline + pad 6 ≈ 62.5dp row pitch, with the
      // divider optically centred between the two messages.
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _leadingSize,
            height: _leadingSize,
            child: _Leading(item: item),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    // 13.4/1.4 is the unique pair that reproduces the
                    // mockup's six line breaks in the 290dp text column
                    // (…active. click / …your personal / …check it) while
                    // matching the measured 18.7dp line spacing.
                    // letterSpacing 0 cancels the theme's 0.25 — the design's
                    // text runs carry no tracking, and 0.25 shifts every one
                    // of those breaks by a word.
                    style: const TextStyle(
                      fontSize: 13.4,
                      height: 1.4,
                      letterSpacing: 0,
                      color: AppColors.gray400,
                    ),
                    children: [
                      for (final segment in item.segments)
                        TextSpan(
                          text: segment.text,
                          style: segment.bold
                              ? const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray900,
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Leading slot: pale bell/person circle (with unread dot) or member photo.
class _Leading extends StatelessWidget {
  const _Leading({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    if (item.kind == NotificationIconKind.avatar) {
      return ClipOval(
        child: Image.asset(
          item.avatarAsset ?? AppAssets.agentAvatar,
          width: _NotificationRow._leadingSize,
          height: _NotificationRow._leadingSize,
          fit: BoxFit.cover,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _NotificationRow._leadingSize,
          height: _NotificationRow._leadingSize,
          decoration: const BoxDecoration(
            color: AppColors.primary100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.kind == NotificationIconKind.bell
                ? Icons.notifications_none
                : Icons.person_outline,
            size: AppDimensions.iconLg,
            color: AppColors.primary,
          ),
        ),
        if (item.unread)
          // Mockup: 4dp dot centred ≈26dp from the circle's left edge and
          // 6dp down — an inset badge inside the arc, not a corner pin.
          const Positioned(
            top: AppDimensions.space4,
            right: AppDimensions.space8 + AppDimensions.space2,
            child: _UnreadDot(),
          ),
      ],
    );
  }
}

/// Red unread dot riding the circle's upper-right arc (the Home bell's dot).
class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.space4,
      height: AppDimensions.space4,
      decoration: const BoxDecoration(
        color: AppColors.error500,
        shape: BoxShape.circle,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state ("No notification yet")
// -----------------------------------------------------------------------------

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mockup: illustration top edge 70.7dp below the header
        // (space64 + space6) and 285dp wide (Opps!! ink 101.1dp).
        const SizedBox(height: AppDimensions.space64 + AppDimensions.space6),
        Center(
          child: Image.asset(
            AppAssets.notificationOops,
            width: 285,
          ),
        ),
        // Mockup: title ink 487.7 — 50dp below the illustration
        // (space48 + space2 on top of the measured hero bottom).
        const SizedBox(height: AppDimensions.space48 + AppDimensions.space2),
        Text(
          'No notification yet',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppDimensions.space16),
        Padding(
          // 40dp side padding keeps the mockup's exact wrap: the line breaks
          // after "…here, so" only while the column stays under ~329dp.
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space40,
          ),
          child: Text(
            'All notification we send will appear here, so you can view them '
            'easly anytime.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              // 15/1.25 → 18.75dp line spacing (mockup: 18.7).
              fontSize: 15,
              height: 1.25,
              color: AppColors.gray400,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Loading skeleton
// -----------------------------------------------------------------------------

/// Static grey placeholders for the first frames of a load. Deliberately
/// static: shimmer/indeterminate animations hang `pumpAndSettle`.
class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingWide,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.space16),
          bar(96, 24),
          const SizedBox(height: AppDimensions.space24),
          for (var i = 0; i < 5; i++) ...[
            Row(
              children: [
                bar(
                  AppDimensions.notificationLeading,
                  AppDimensions.notificationLeading,
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(220, 14),
                      const SizedBox(height: AppDimensions.space8),
                      bar(160, 14),
                      const SizedBox(height: AppDimensions.space12),
                      bar(double.infinity, 1),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ],
      ),
    );
  }
}
