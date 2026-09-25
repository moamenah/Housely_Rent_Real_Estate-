/// Asset paths — the single place that knows where files live.
///
/// Register new folders under the `assets:` section of `pubspec.yaml` and
/// expose them here so widgets never hard-code a path.
abstract final class AppAssets {
  AppAssets._();

  /// Brand pin used by the splash screen.
  static const String appLogo = 'assets/images/app_logo.svg';

  static const String onBoarding1 = 'assets/images/onBoarding_1.png';
  static const String onBoarding2 = 'assets/images/onBoarding_2.png';
  static const String onBoarding3 = 'assets/images/onBoarding_3.png';

  // ── Auth ────────────────────────────────────────────────────────────────
  /// Password revealed / hidden toggles (same stroke style as the design kit).
  static const String showIcon = 'assets/icons/Show.svg';
  static const String hideIcon = 'assets/icons/Hide.svg';

  static const String googleIcon = 'assets/icons/google.svg';
  static const String facebookIcon = 'assets/icons/facebook.svg';

  /// Password-recovery flow: masked contact options + success hero.
  static const String phoneIcon = 'assets/icons/phone.svg';
  static const String mailIcon = 'assets/icons/mail.svg';
  static const String passwordSuccessIcon =
      'assets/icons/password_success.svg';

  /// Location step: "Hi, Nice to meet you !" hero (map + magnifier scene).
  static const String locationIllustration =
      'assets/icons/location_illustration.svg';
}
