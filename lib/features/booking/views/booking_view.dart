import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/extensions/number_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../../properties/models/property.dart';
import '../../properties/viewmodels/properties_cubit.dart';
import '../../properties/viewmodels/properties_state.dart';
import '../models/payment_card.dart';
import '../viewmodels/booking_cubit.dart';
import '../viewmodels/booking_state.dart';
import 'widgets/booking_property_card.dart';
import 'widgets/booking_success_sheet.dart';
import 'widgets/select_date_sheet.dart';

/// The Booking checkout — property card, period, payments and price details.
///
/// Reached from two places with the same screen: the My Booking tab (shows
/// the session's current booking, Batavia Apartments by default) and the
/// details screen's "Rent now" (after [BookingCubit.startBooking]). The
/// session ViewModel sits above the router, so a card saved through the
/// Add Card form is attached on either entry.
class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listenWhen: (previous, current) =>
          (current.hasConfirmed && !previous.hasConfirmed) ||
          (current.hasFailed && !previous.hasFailed),
      listener: (context, state) {
        if (state.hasConfirmed) {
          BookingSuccessSheet.show(
            context,
            onExplore: () => context.go(RoutePaths.explore),
          );
        } else {
          context.showSnack(
            state.failure?.message ??
                'We could not confirm your booking. Please try again.',
          );
        }
      },
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, booking) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Booking'),
              centerTitle: true,
              // The mockup draws a back arrow: pops a pushed checkout,
              // returns to Home when reached from the tab.
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.goBackTo(RoutePaths.home),
              ),
            ),
            body: BlocBuilder<PropertiesCubit, PropertiesState>(
              builder: (context, properties) {
                final property = properties.propertyById(booking.propertyId);

                if (property == null) {
                  if (properties.isLoading) {
                    // Static placeholder — never an indeterminate spinner.
                    return const _BookingSkeleton();
                  }
                  return ErrorView(
                    message: 'We could not load this listing.',
                    onRetry: () =>
                        context.read<PropertiesCubit>().fetchProperties(),
                  );
                }

                return _CheckoutBody(booking: booking, property: property);
              },
            ),
            // The design pins "Confirm and Pay" only once a payment method
            // exists (second mockup); without one the screen just scrolls.
            bottomNavigationBar: booking.hasCard
                ? _ConfirmBar(
                    key: const Key('booking_confirm'),
                    onConfirm: booking.isConfirming
                        ? null
                        : () => context.read<BookingCubit>().confirm(),
                  )
                : null,
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Checkout content
// -----------------------------------------------------------------------------

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({required this.booking, required this.property});

  final BookingState booking;
  final Property property;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.space16,
        AppDimensions.pagePadding,
        AppDimensions.space32,
      ),
      children: [
        BookingPropertyCard(property: property),
        const SizedBox(height: AppDimensions.space24),
        const _SectionHeader('Period'),
        const SizedBox(height: AppDimensions.space4),
        _PeriodRow(
          booking: booking,
          onTap: () => SelectDateSheet.show(
            context,
            initialStart: booking.periodStart,
            initialEnd: booking.periodEnd,
            onSave: (start, end) =>
                context.read<BookingCubit>().setPeriod(start, end),
          ),
        ),
        const Divider(),
        // The mockup shows the date warning only before a payment method
        // has been picked — once a card is attached the sheet moves on.
        if (!booking.hasCard) ...[
          const SizedBox(height: AppDimensions.space12),
          Text(
            'Make sure to check your date before making any sort of payments',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.space24),
        const _SectionHeader('Payments'),
        const SizedBox(height: AppDimensions.space4),
        if (booking.hasCard)
          _SavedCardRow(
            card: booking.card!,
            onEdit: () => context.push(RoutePaths.addCard),
          )
        else ...[
          _PaymentOption(
            key: const Key('booking_add_credit'),
            icon: AppAssets.bookingCreditIcon,
            tileShape: _IconTileShape.rounded,
            label: 'Credit or Debit card',
            onTap: () => context.push(RoutePaths.addCard),
          ),
          _PaymentOption(
            key: const Key('booking_add_paypal'),
            icon: AppAssets.bookingPaypalIcon,
            tileShape: _IconTileShape.circle,
            label: 'Paypal',
            onTap: () => context.showSnack(
              "Paypal checkout isn't available in this build yet.",
            ),
          ),
        ],
        const Divider(),
        const SizedBox(height: AppDimensions.space4),
        _VoucherRow(
          onTap: () =>
              context.showSnack("Vouchers aren't available in this build yet."),
        ),
        const SizedBox(height: AppDimensions.space24),
        const _SectionHeader('Price Details'),
        const SizedBox(height: AppDimensions.space4),
        _PriceDetails(property: property, durationLabel: booking.durationLabel),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Period
// -----------------------------------------------------------------------------

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.booking, required this.onTap});

  final BookingState booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return InkWell(
      key: const Key('booking_date_row'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
        child: Row(
          children: [
            const _IconTile(
              icon: AppAssets.bookingCalendar,
              shape: _IconTileShape.circle,
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: theme.bodySmall),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    booking.periodLabel,
                    style: theme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: AppDimensions.iconLg,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Payments
// -----------------------------------------------------------------------------

enum _IconTileShape { circle, rounded }

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.shape});

  final String icon;
  final _IconTileShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.space48,
      height: AppDimensions.space48,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        shape: shape == _IconTileShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == _IconTileShape.rounded
            ? const BorderRadius.all(
                Radius.circular(AppDimensions.radiusLg),
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        icon,
        width: AppDimensions.iconLg,
        height: AppDimensions.iconLg,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    super.key,
    required this.icon,
    required this.tileShape,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final _IconTileShape tileShape;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
        child: Row(
          children: [
            _IconTile(icon: icon, shape: tileShape),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(label, style: context.textTheme.bodyLarge),
            ),
            const Icon(
              Icons.add,
              size: AppDimensions.iconLg,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCardRow extends StatelessWidget {
  const _SavedCardRow({required this.card, required this.onEdit});

  final PaymentCard card;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        children: [
          Image.asset(
            AppAssets.bookingMastercard,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              card.masked,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyLarge,
            ),
          ),
          InkWell(
            key: const Key('booking_edit_card'),
            onTap: onEdit,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Text(
                'Edit',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherRow extends StatelessWidget {
  const _VoucherRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('booking_voucher'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter a Voucher',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Price details
// -----------------------------------------------------------------------------

class _PriceDetails extends StatelessWidget {
  const _PriceDetails({required this.property, required this.durationLabel});

  final Property property;
  final String durationLabel;

  /// Flat booking tax from the design's breakdown (the mockup's `$10.00`).
  static const double _tax = 10;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PriceRow(label: 'Period time', value: durationLabel),
        _PriceRow(
          label: 'Monthly payment',
          value: property.price.toPrice(decimals: 2),
        ),
        _PriceRow(label: 'Tax', value: _tax.toPrice(decimals: 2)),
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.space8),
          child: Row(
            children: [
              Text(
                'Total',
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                (property.price + _tax).toPrice(decimals: 2),
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        children: [
          // Expanded + ellipsis: the label shrinks instead of overflowing
          // when the test font runs wide (the value stays pinned right).
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Text(
            value,
            style: theme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Pinned CTA
// -----------------------------------------------------------------------------

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({super.key, required this.onConfirm});

  /// `null` while the confirm request is in flight (the mock backend keeps
  /// the button disabled for its latency — no spinner anywhere).
  final VoidCallback? onConfirm;

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
          onPressed: onConfirm,
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
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: const Text('Confirm and Pay'),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Loading skeleton
// -----------------------------------------------------------------------------

/// Static grey blocks shown while the listing corpus is still loading.
class _BookingSkeleton extends StatelessWidget {
  const _BookingSkeleton();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.space16),
          bar(double.infinity, 120),
          const SizedBox(height: AppDimensions.space24),
          bar(120, 20),
          const SizedBox(height: AppDimensions.space16),
          bar(double.infinity, 56),
          const SizedBox(height: AppDimensions.space24),
          bar(140, 20),
          const SizedBox(height: AppDimensions.space16),
          bar(double.infinity, 56),
          const SizedBox(height: AppDimensions.space8),
          bar(double.infinity, 56),
        ],
      ),
    );
  }
}
