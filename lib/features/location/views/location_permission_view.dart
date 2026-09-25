import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../auth/views/widgets/auth_cta_button.dart';

/// "Hi, Nice to meet you !" — the location step between auth and the shell.
///
/// Pure navigation and one stub: there is no async work or validation here,
/// so this screen deliberately has no Cubit (an MVVM layer is only worth its
/// weight when there is state to own).
class LocationPermissionView extends StatelessWidget {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.space12,
            AppDimensions.pagePadding,
            AppDimensions.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  TextButton(
                    key: const Key('location_skip_button'),
                    onPressed: () => context.go(RoutePaths.explore),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.gray700,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space20,
                        vertical: AppDimensions.space8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.locationIllustration,
                      width: 330,
                      semanticsLabel: 'Map with a magnifying glass finding a home',
                    ),
                    const SizedBox(height: AppDimensions.space40),
                    Text(
                      'Hi, Nice to meet you !',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Choose your location to find property around you',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              AuthCtaButton(
                label: 'Use current location',
                buttonKey: const Key('location_use_current_button'),
                onPressed: () => context.showSnack(
                  "Using your current location isn't available "
                  'in this build yet.',
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              OutlinedButton(
                key: const Key('location_manual_button'),
                onPressed: () => context.go(RoutePaths.locationPicker),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primary),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Select it manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
