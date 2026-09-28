import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/sign_up_view.dart';
import '../../features/booking/views/add_card_view.dart';
import '../../features/booking/views/booking_view.dart';
import '../../features/booking/views/my_bookings_view.dart';
import '../../features/booking/repositories/my_booking_repository.dart';
import '../../features/favorites/views/favorites_view.dart';
import '../../features/home/repositories/home_repository.dart';
import '../../features/home/views/home_view.dart';
import '../../features/home/views/popular_view.dart';
import '../../features/location/repositories/location_repository.dart';
import '../../features/location/views/location_permission_view.dart';
import '../../features/location/views/location_picker_view.dart';
import '../../features/notifications/repositories/notification_repository.dart';
import '../../features/notifications/views/notification_view.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/password_recovery/repositories/password_recovery_repository.dart';
import '../../features/password_recovery/viewmodels/password_recovery_cubit.dart';
import '../../features/password_recovery/views/create_password_view.dart';
import '../../features/password_recovery/views/forgot_password_view.dart';
import '../../features/password_recovery/views/password_changed_view.dart';
import '../../features/password_recovery/views/verify_code_view.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/profile/views/edit_profile_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/properties/repositories/property_repository.dart';
import '../../features/properties/views/properties_view.dart';
import '../../features/properties/views/property_details_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../di/injection.dart';
import '../widgets/error_view.dart';
import 'route_paths.dart';

/// Root navigator key — lets the shell routes push full-screen pages above the
/// bottom navigation bar.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// App-wide router.
///
/// Topology:
/// ```text
/// /splash                          ← cold start, one-shot (go() removes it)
/// /onboarding                      ← intro carousel, only reachable from splash
/// /login                           ← sign in, after onboarding
/// /signup                          ← registration, from the sign-in screen
/// /location-permission             ← "Hi, Nice to meet you !", after auth
/// /location-picker                 ← map + address card (select manually)
/// ShellRoute (PasswordRecoveryCubit) ← one Cubit spans the whole wizard
/// ├── /forgot-password   ← pick a masked contact
/// ├── /verify-code       ← 6-digit code
/// ├── /reset-password    ← new password
/// └── /password-changed  ← success, back to /login
/// StatefulShellRoute.indexedStack   ← keeps each branch's state alive
/// ├── /home        (HomeView — location header, search, promo, 4 rails)
/// ├── /explore     (PropertiesView)
/// ├── /favorites   (FavoritesView)
/// ├── /bookings    (BookingView — the session's current checkout)
/// └── /profile     (ProfileView)
/// /profile/edit                    ← full screen, above the shell
/// /notifications                   ← full screen, from the Home bell or
///                                    the Profile menu's Notification row
/// /property/:id                    ← full screen, above the shell
/// /booking                         ← full screen, pushed by "Rent now"
/// /booking/add-card                ← full screen, pushed by the checkout
/// ```
/// The auth screens land on `/location-permission`, so every session passes
/// the greeting/location step before the shell (`Skip`, *Use current
/// location* — stubbed — and *Choose location* all resolve to `/explore`).
/// Because every hop is a `go()` (a location change, not a push), the system
/// back button never walks backwards through splash → onboarding; at those
/// screens it simply exits the app.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => SplashView(
        // Anything registered as async in get_it is awaited before the shell
        // is revealed; synchronous graphs resolve immediately.
        bootstrap: () async => sl.allReady(),
      ),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => LoginView(authRepository: sl<AuthRepository>()),
    ),
    GoRoute(
      path: RoutePaths.signup,
      name: RouteNames.signup,
      builder: (context, state) =>
          SignUpView(authRepository: sl<AuthRepository>()),
    ),
    // ── Location step ─────────────────────────────────────────────────────
    GoRoute(
      path: RoutePaths.locationPermission,
      name: RouteNames.locationPermission,
      builder: (context, state) => const LocationPermissionView(),
    ),
    GoRoute(
      path: RoutePaths.locationPicker,
      name: RouteNames.locationPicker,
      builder: (context, state) => LocationPickerView(
        locationRepository: sl<LocationRepository>(),
      ),
    ),
    // Password recovery is one wizard in four screens: this ShellRoute owns
    // the single Cubit (chosen contact → typed code → new password) so the
    // shared state survives every `go()` between the steps, while each leaf
    // route only decides where to go next.
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => PasswordRecoveryCubit(
          repository: sl<PasswordRecoveryRepository>(),
        )..loadContacts(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordView(),
        ),
        GoRoute(
          path: RoutePaths.verifyCode,
          name: RouteNames.verifyCode,
          builder: (context, state) => const VerifyCodeView(),
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          name: RouteNames.resetPassword,
          builder: (context, state) => const CreatePasswordView(),
        ),
        GoRoute(
          path: RoutePaths.passwordChanged,
          name: RouteNames.passwordChanged,
          builder: (context, state) => const PasswordChangedView(),
        ),
      ],
    ),
    // The design's five-tab bar: branch order is the tab order.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (context, state) =>
                  HomeView(homeRepository: sl<HomeRepository>()),
            ),
            GoRoute(
              path: RoutePaths.popular,
              name: RouteNames.popular,
              builder: (context, state) =>
                  PopularView(homeRepository: sl<HomeRepository>()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.explore,
              name: RouteNames.explore,
              builder: (context, state) => const PropertiesView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.favorites,
              name: RouteNames.favorites,
              builder: (context, state) => const FavoritesView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.bookings,
              name: RouteNames.bookings,
              builder: (context, state) => MyBookingsView(
                myBookingRepository: sl<MyBookingRepository>(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.profile,
              name: RouteNames.profile,
              builder: (context, state) =>
                  ProfileView(profileRepository: sl<ProfileRepository>()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.profileEdit,
      name: RouteNames.profileEdit,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          EditProfileView(profileRepository: sl<ProfileRepository>()),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      name: RouteNames.notifications,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => NotificationView(
        notificationRepository: sl<NotificationRepository>(),
      ),
    ),
    GoRoute(
      path: RoutePaths.propertyDetails,
      name: RouteNames.propertyDetails,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => PropertyDetailsView(
        propertyId: state.pathParameters['id'] ?? '',
        propertyRepository: sl<PropertyRepository>(),
      ),
    ),
    GoRoute(
      path: RoutePaths.booking,
      name: RouteNames.booking,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BookingView(),
    ),
    GoRoute(
      path: RoutePaths.addCard,
      name: RouteNames.addCard,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddCardView(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page not found')),
    body: ErrorView(
      message: 'The page you are looking for does not exist.',
      onRetry: () => context.go(RoutePaths.explore),
      retryLabel: 'Back to home',
    ),
  ),
);

/// App scaffold: host page + the design's five-tab bottom bar.
///
/// The active tab is drawn exactly as the mockup does it — a purple
/// indicator line on top of the item, purple icon and label — which
/// Material's `NavigationBar` (pill *behind* the icon) cannot express.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Design order: Home · Explore · Favorite · My Booking · Profile.
  /// `(icon, selectedIcon, label)`.
  static const List<(IconData, IconData, String)> destinations = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.explore_outlined, Icons.explore, 'Explore'),
    (Icons.favorite_border, Icons.favorite, 'Favorite'),
    (Icons.description_outlined, Icons.description, 'My Booking'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppDimensions.bottomNavBarHeight,
            child: Row(
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _ShellTab(
                      icon: destinations[index].$1,
                      selectedIcon: destinations[index].$2,
                      label: destinations[index].$3,
                      selected: index == currentIndex,
                      onTap: () => navigationShell.goBranch(
                        index,
                        // Only reset a branch when its own tab is tapped again.
                        initialLocation: index == currentIndex,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One bottom-nav item: indicator + icon + label.
class _ShellTab extends StatelessWidget {
  const _ShellTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.gray400;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: AppDimensions.iconLg,
                  color: color,
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: color,
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
