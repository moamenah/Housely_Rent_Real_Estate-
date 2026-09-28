import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../repositories/profile_repository.dart';
import '../viewmodels/profile_cubit.dart';
import '../viewmodels/profile_state.dart';
import 'widgets/profile_avatar.dart';

/// Account hub — portrait, identity, settings rows, sign-out.
///
/// Entry point of `Edit Profile`: the design offers no explicit edit button,
/// so the portrait is the affordance (same as the camera badge implies).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.profileRepository});

  /// Injected by the router so the View never touches the service locator.
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(profileRepository: profileRepository)
        ..load(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  /// Design order: Settings · Payment · Notification · Recent Viewed · About.
  static const List<(IconData, String)> _menuItems = [
    (Icons.settings_outlined, 'Settings'),
    (Icons.account_balance_wallet_outlined, 'Payment'),
    (Icons.notifications_outlined, 'Notification'),
    (Icons.history, 'Recent Viewed'),
    (Icons.info_outline, 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        // Losing the account is transport-scoped → banner; the content area
        // still offers an inline retry.
        if (state.hasFailed) {
          context.showSnack(
            state.failure?.message ?? 'We could not load your profile.',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space8,
                    AppDimensions.space4,
                    AppDimensions.space8,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('profile_back_button'),
                        onPressed: () =>
                            context.goBackTo(RoutePaths.explore),
                        icon: const Icon(Icons.arrow_back_outlined),
                        color: AppColors.gray900,
                        iconSize: 26,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Profile',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48, height: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading || state.profile == null
                      ? state.hasFailed
                          ? ErrorView(
                              message: state.failure?.message ??
                                  'We could not load your profile.',
                              onRetry: cubit.load,
                            )
                          : const Padding(
                              padding:
                                  EdgeInsets.only(top: AppDimensions.space64),
                              child: AppLoadingIndicator(),
                            )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.pagePadding,
                            AppDimensions.space16,
                            AppDimensions.pagePadding,
                            AppDimensions.space24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: ProfileAvatar(
                                  key: const Key('profile_avatar_button'),
                                  name: state.profile!.name,
                                  onTap: () =>
                                      context.go(RoutePaths.profileEdit),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space20),
                              Center(
                                child: Text(
                                  state.profile!.name,
                                  style: context.textTheme.titleLarge
                                      ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Center(
                                child: Text(
                                  state.profile!.email,
                                  style: context.textTheme.bodyLarge
                                      ?.copyWith(
                                    fontSize: 16,
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              const Divider(),
                              for (final (icon, label) in _menuItems)
                                _MenuRow(
                                  icon: icon,
                                  label: label,
                                  // Notification is the one row the design
                                  // ships a screen for; the rest are stubs.
                                  onTap: () {
                                    if (label == 'Notification') {
                                      context.push(RoutePaths.notifications);
                                      return;
                                    }
                                    context.showSnack(
                                      "$label isn't available "
                                      'in this build yet.',
                                    );
                                  },
                                ),
                              const SizedBox(height: AppDimensions.space8),
                              Center(
                                child: TextButton(
                                  key: const Key('profile_sign_out_button'),
                                  onPressed: () =>
                                      context.go(RoutePaths.login),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.space24,
                                      vertical: AppDimensions.space12,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Sign Out'),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One settings row: purple outline icon · label · chevron.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space16,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimensions.iconLg, color: AppColors.primary),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.gray900,
                ),
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
