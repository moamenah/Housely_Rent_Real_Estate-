/// Central registry of navigation paths & route names.
///
/// Views navigate with `context.go(RoutePaths.property(id))` /
/// `context.push(...)` — a path string is never written inline in a widget.
abstract final class RoutePaths {
  RoutePaths._();

  /// Cold-start brand screen.
  static const String splash = '/splash';

  /// Intro carousel, shown right after the splash.
  static const String onboarding = '/onboarding';

  /// Sign-in screen, shown after onboarding.
  static const String login = '/login';

  /// Registration screen, reachable from the sign-in screen.
  static const String signup = '/signup';

  // ── Location step (between auth and the shell) ──────────────────────────
  /// "Hi, Nice to meet you !" — permission/greeting screen, after auth.
  static const String locationPermission = '/location-permission';

  /// Map screen: drop a pin, search, confirm the address.
  static const String locationPicker = '/location-picker';

  // ── Bottom-nav branches (design order: Home · Explore · Favorite ·
  //    My Booking · Profile) ────────────────────────────────────────────────
  /// Bottom-nav branch: Home (the landing feed).
  static const String home = '/home';

  /// "Popular for you" list — pushed *inside* the Home branch, so the tab
  /// bar stays visible and the back arrow returns to the feed.
  static const String popular = '/home/popular';

  /// Bottom-nav branch: property feed.
  static const String explore = '/explore';

  /// Bottom-nav branch: saved listings.
  static const String favorites = '/favorites';

  /// Bottom-nav branch: My Booking — the three-segment stay list (the
  /// checkout lives on [booking], pushed from the details screen).
  static const String bookings = '/bookings';

  /// Checkout screen, full-screen above the shell (pushed by "Rent now").
  static const String booking = '/booking';

  /// Card form pushed on top of the checkout.
  static const String addCard = '/booking/add-card';

  /// Bottom-nav branch: account hub.
  static const String profile = '/profile';

  /// Profile editing form, full-screen above the shell (has a back arrow).
  static const String profileEdit = '/profile/edit';

  /// Notification inbox, full-screen above the shell (pushed by the Home
  /// bell and by the Profile menu's Notification row).
  static const String notifications = '/notifications';

  /// Full-screen detail page, above the shell navigator.
  static const String propertyDetails = '/property/:id';

  static String property(String id) => '/property/$id';

  // ── Password recovery (one flow, four screens) ───────────────────────────
  /// Step 1: pick which masked contact receives the reset code.
  static const String forgotPassword = '/forgot-password';

  /// Step 2: enter the emailed code.
  static const String verifyCode = '/verify-code';

  /// Step 3: choose the new password.
  static const String resetPassword = '/reset-password';

  /// Step 4: confirmation, then back to sign-in.
  static const String passwordChanged = '/password-changed';
}

/// Human-readable route names, useful for `GoRouterState.name` checks and logs.
abstract final class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String locationPermission = 'location-permission';
  static const String locationPicker = 'location-picker';
  static const String forgotPassword = 'forgot-password';
  static const String verifyCode = 'verify-code';
  static const String resetPassword = 'reset-password';
  static const String passwordChanged = 'password-changed';
  static const String home = 'home';
  static const String popular = 'popular';
  static const String explore = 'explore';
  static const String favorites = 'favorites';
  static const String bookings = 'bookings';
  static const String booking = 'booking';
  static const String addCard = 'add-card';
  static const String profile = 'profile';
  static const String profileEdit = 'profile-edit';
  static const String notifications = 'notifications';
  static const String propertyDetails = 'property-details';
}
