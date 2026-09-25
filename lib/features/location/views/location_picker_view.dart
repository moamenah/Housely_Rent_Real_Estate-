import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/views/widgets/auth_cta_button.dart';
import '../repositories/location_repository.dart';
import '../viewmodels/location_picker_cubit.dart';
import '../viewmodels/location_picker_state.dart';
import 'widgets/map_canvas.dart';

/// Map screen — drop a pin, search an address, confirm it.
///
/// The canvas, marker, search pill, "Location Details" card and the final
/// CTA are one composition on purpose: the card is the only region that
/// reacts to the ViewModel (loading / failure / chosen address).
class LocationPickerView extends StatelessWidget {
  const LocationPickerView({super.key, required this.locationRepository});

  /// Injected by the router so the View never touches the service locator.
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationPickerCubit(
        locationRepository: locationRepository,
      )..loadPinnedPlace(),
      child: const _LocationPickerBody(),
    );
  }
}

class _LocationPickerBody extends StatelessWidget {
  const _LocationPickerBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationPickerCubit, LocationPickerState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSearching != current.isSearching,
      listener: (context, state) {
        // Every failure on this screen is transport-scoped, so it is
        // announced as a banner; the card additionally offers an inline
        // retry when it is the pinned-place load that broke.
        if (state.failure != null) {
          context.showSnack(state.failure!.message, isError: true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<LocationPickerCubit>();

        return Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: MapCanvas()),
              const Positioned.fill(
                child: Align(
                  alignment: Alignment(0, -0.10),
                  child: Icon(
                    Icons.place,
                    size: 58,
                    color: AppColors.mapMarker,
                    shadows: [
                      Shadow(color: AppColors.black26, blurRadius: 8),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePadding,
                    AppDimensions.space8,
                    AppDimensions.pagePadding,
                    AppDimensions.space20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          key: const Key('location_picker_back_button'),
                          onPressed: () => context
                              .goBackTo(RoutePaths.locationPermission),
                          icon: const Icon(Icons.arrow_back_outlined),
                          color: AppColors.gray900,
                          iconSize: 26,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      _SearchPill(state: state, cubit: cubit),
                      const Spacer(),
                      _DetailsCard(state: state, cubit: cubit),
                      const SizedBox(height: AppDimensions.space16),
                      AuthCtaButton(
                        label: 'Choose location',
                        buttonKey: const Key('location_choose_button'),
                        onPressed: state.canChoose
                            ? () => context.go(RoutePaths.explore)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// White pill input floating on top of the map.
class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.state, required this.cubit});

  final LocationPickerState state;
  final LocationPickerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black08,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        key: const Key('location_search_field'),
        onChanged: cubit.queryChanged,
        onSubmitted: (_) => cubit.search(),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 15, color: AppColors.gray900),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: 'Search Location',
          hintStyle: const TextStyle(fontSize: 15, color: AppColors.gray400),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
            size: AppDimensions.iconLg,
          ),
          suffixIcon: state.isSearching
              ? const Padding(
                  padding: EdgeInsets.all(AppDimensions.space12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space8,
            vertical: AppDimensions.space16,
          ),
        ),
      ),
    );
  }
}

/// The "Location Details" card: title + address (or its loading/failure UI).
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.state, required this.cubit});

  final LocationPickerState state;
  final LocationPickerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black10,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          if (state.status == RequestStatus.failure)
            ErrorView(
              message: state.failure?.message ??
                  'We could not load the location.',
              onRetry: cubit.loadPinnedPlace,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: state.isLoadingPlace || state.place == null
                      ? const AppLoadingIndicator(size: 24)
                      : Text(
                          state.place!.address,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: AppColors.gray500,
                          ),
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
