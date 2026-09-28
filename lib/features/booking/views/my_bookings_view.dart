import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../models/my_booking.dart';
import '../repositories/my_booking_repository.dart';
import '../viewmodels/my_bookings_cubit.dart';
import '../viewmodels/my_bookings_state.dart';

/// My Booking — the design's three-segment stay list (Upcoming · Completed ·
/// Cancelled) with its cards, per-segment action rows and empty state.
///
/// **View responsibilities only**: render [MyBookingsState], forward segment
/// taps and retries to [MyBookingsCubit]. Lives in the shell's fourth tab, so
/// the mockup's back arrow steps back to Home like the other tab screens.
class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key, required this.myBookingRepository});

  /// Injected by the router so the View never touches the service locator.
  final MyBookingRepository myBookingRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyBookingsCubit(myBookingRepository: myBookingRepository)
        ..load(),
      child: const _MyBookingsBody(),
    );
  }
}

class _MyBookingsBody extends StatelessWidget {
  const _MyBookingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _MyBookingsHeader(),
            const _SegmentControl(),
            Expanded(
              child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
                builder: (context, state) {
                  if (state.hasFailed) {
                    // No fixed-height wrapper: ErrorView shrink-wraps.
                    return ErrorView(
                      message: state.failure?.message ??
                          'Your bookings could not be loaded.',
                      onRetry: context.read<MyBookingsCubit>().load,
                    );
                  }

                  if (!state.isLoaded) {
                    // First frames of the load — static skeleton, never an
                    // indeterminate spinner (it would hang `pumpAndSettle`).
                    return const _BookingsSkeleton();
                  }

                  if (state.isEmpty) {
                    return const _EmptyBookings();
                  }

                  return _BookingsList(bookings: state.visible);
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
// Hand-built row like the inbox header: the mockup centres the title on the
// *screen*, which a leading button would shift off-centre.
class _MyBookingsHeader extends StatelessWidget {
  const _MyBookingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space12,
        AppDimensions.space4,
        AppDimensions.space12,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('my_bookings_back_button'),
            onPressed: () => context.goBackTo(RoutePaths.home),
            icon: const Icon(Icons.arrow_back_outlined),
            color: AppColors.gray900,
            iconSize: 26,
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Booking',
                style: context.textTheme.titleLarge?.copyWith(
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
// Segment control (Upcoming · Completed · Cancelled)
// -----------------------------------------------------------------------------

class _SegmentControl extends StatelessWidget {
  const _SegmentControl();

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<MyBookingsCubit>().state.selected;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingWide,
        AppDimensions.space12,
        AppDimensions.pagePaddingWide,
        AppDimensions.space16,
      ),
      child: Container(
        // Mockup: 40dp track on the 25dp page gutter, pill radius throughout.
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            for (final status in BookingStatus.values)
              Expanded(
                child: _Segment(status: status, active: status == selected),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.status, required this.active});

  final BookingStatus status;
  final bool active;

  static const Map<BookingStatus, String> labels = {
    BookingStatus.upcoming: 'Upcoming',
    BookingStatus.completed: 'Completed',
    BookingStatus.cancelled: 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<MyBookingsCubit>().select(status),
      child: Container(
        alignment: Alignment.center,
        decoration: active
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              )
            : null,
        child: Text(
          labels[status]!,
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.textOnPrimary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Booking cards
// -----------------------------------------------------------------------------

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.bookings});

  final List<MyBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingWide,
        0,
        AppDimensions.pagePaddingWide,
        AppDimensions.space32,
      ),
      children: [
        for (final booking in bookings) _BookingBlock(booking: booking),
      ],
    );
  }
}

/// One booking: the card, then the segment's action rows — each block
/// separated by the mockup's full-width hairline.
class _BookingBlock extends StatelessWidget {
  const _BookingBlock({required this.booking});

  final MyBooking booking;

  List<_Action> get _actions => switch (booking.status) {
        BookingStatus.completed => [_Action.writeReview, _Action.callAgent],
        BookingStatus.cancelled => [_Action.callAgent],
        BookingStatus.upcoming => [],
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BookingCard(booking: booking),
        const Divider(height: 1),
        for (final action in _actions) ...[
          _ActionRow(action: action),
          const Divider(height: 1),
        ],
      ],
    );
  }
}

/// Card row: thumbnail · title + location + (dates · badge).
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final MyBooking booking;

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        booking.badgeTone == BookingBadgeTone.danger ? AppColors.error500 : AppColors.success500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Image.asset(
              booking.imageUrl,
              // Mockup thumbnail: 88 × 67dp.
              width: 88,
              height: 67,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppDimensions.iconSm,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Expanded(
                      child: Text(
                        booking.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          letterSpacing: 0,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    // Flexible + ellipsis: the mockup keeps the badge on
                    // the right edge even when the dates are long.
                    Flexible(
                      child: Text(
                        booking.dates,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          letterSpacing: 0,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: booking.badgeTone == BookingBadgeTone.danger
                            ? AppColors.error100
                            : AppColors.success100,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        booking.badge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The follow-up rows under a Completed/Cancelled booking ("Write review",
/// "Call Agent") — purple icon + muted label, hairline below.
enum _Action {
  writeReview('Write review', AppAssets.bookingReview,
      "Reviews aren't available in this build yet."),
  callAgent('Call Agent', AppAssets.bookingCall,
      "Calling isn't available in this build yet.");

  const _Action(this.label, this.asset, this.stubMessage);

  final String label;
  final String asset;
  final String stubMessage;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.showSnack(action.stubMessage),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
        child: Row(
          children: [
            Image.asset(
              action.asset,
              width: AppDimensions.iconLg,
              height: AppDimensions.iconLg,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: AppDimensions.space12),
            Text(
              action.label,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                letterSpacing: 0,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state ("You have no upcoming booking")
// -----------------------------------------------------------------------------

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mockup: the "Opps!!" script sits just above the illustration.
        const SizedBox(height: AppDimensions.space64 + AppDimensions.space16),
        Text(
          'Opps!!',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: 0,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        Center(
          child: Image.asset(
            AppAssets.bookingOops,
            width: 300,
          ),
        ),
        // Mockup: 50dp from the illustration to the headline.
        const SizedBox(height: AppDimensions.space48 + AppDimensions.space2),
        Text(
          // "You have no upcoming booking" — the segment name, lowercase.
          'You have no '
          '${context.watch<MyBookingsCubit>().state.selected.name} booking',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppDimensions.space20),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space40,
          ),
          child: Text.rich(
            TextSpan(
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
                letterSpacing: 0,
                color: AppColors.gray400,
              ),
              children: [
                const TextSpan(text: 'are you looking fo a '),
                const TextSpan(
                  text: 'completed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' or '),
                const TextSpan(
                  text: 'cancelled',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' booking ?'),
              ],
            ),
            textAlign: TextAlign.center,
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
class _BookingsSkeleton extends StatelessWidget {
  const _BookingsSkeleton();

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
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                bar(88, 67),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(160, 14),
                      const SizedBox(height: AppDimensions.space8),
                      bar(200, 12),
                      const SizedBox(height: AppDimensions.space8),
                      bar(120, 12),
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
