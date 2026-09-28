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

  // ── Home ────────────────────────────────────────────────────────────────
  /// Promo banner rendered by the Home screen ("GET YOUR 20% CASHBACK").
  static const String bannerPromo = 'assets/images/Banner_2.png';

  /// Loft interior that doubles as a listing photo (Sindu Praya Loft).
  static const String detailsLoft = 'assets/images/details_3.png';

  // Listing photos (the design kit's gallery export).
  static const String gallery1 = 'assets/images/gallery_1.png';
  static const String gallery2 = 'assets/images/gallery_2.png';
  static const String gallery3 = 'assets/images/gallery_3.png';
  static const String gallery4 = 'assets/images/gallery_4.png';
  static const String gallery5 = 'assets/images/gallery_5.png';
  static const String gallery6 = 'assets/images/gallery_6.png';
  static const String gallery7 = 'assets/images/gallery_7.png';
  static const String gallery8 = 'assets/images/gallery_8.png';
  static const String gallery9 = 'assets/images/gallery_9.png';

  // ── Details ─────────────────────────────────────────────────────────────
  /// Interior shots that extend the details carousel past the cover photo.
  static const String detailsInterior1 = 'assets/images/details_1.png';
  static const String detailsInterior2 = 'assets/images/details_2.png';
  static const String detailsInterior3 = 'assets/images/details_3.png';
  static const String detailsInterior4 = 'assets/images/details_4.png';

  /// The full details carousel: cover photo first, then the kit's interiors.
  static const List<String> detailsInteriors = [
    detailsInterior1,
    detailsInterior2,
    detailsInterior3,
    detailsInterior4,
  ];

  /// People: the listing agent and the review author avatars.
  static const String agentAvatar = 'assets/images/profile_1.png';
  static const String reviewerAvatar = 'assets/images/profile_2.png';

  // ── Share sheet ─────────────────────────────────────────────────────────
  static const String shareFacebook = 'assets/images/facebook.png';
  static const String shareInsta = 'assets/images/insta.png';
  static const String shareTwitter = 'assets/images/twitter.png';
  static const String shareWhatsapp = 'assets/images/whatsapp.png';
  static const String shareLinkedin = 'assets/images/linkedin.png';
  static const String sharePinterest = 'assets/images/pinterest.png';

  // ── Booking flow ────────────────────────────────────────────────────────
  /// Calendar glyph for the period row and the "Select Date" sheet.
  static const String bookingCalendar = 'assets/images/date.png';

  /// Payment option glyphs (transparent icons, sized onto pale-purple tiles).
  static const String bookingCreditIcon = 'assets/images/credit.png';
  static const String bookingPaypalIcon = 'assets/images/paypal.png';

  /// The Add Card screen's card artwork — gradient, cardholder, number and
  /// the Mastercard mark are all baked into this export.
  static const String bookingCardArt = 'assets/images/Credit Card.png';

  /// Saved-card row mark (circles + wordmark) next to "...........3321".
  static const String bookingMastercard = 'assets/images/mastercard.png';

  /// Success sheet illustration — includes its own pale-purple disc.
  static const String bookingSuccess = 'assets/images/booking_success.png';

  // ── Notifications ───────────────────────────────────────────────────────
  /// "Opps!!" mailbox hero of the empty inbox (the headline is baked in).
  static const String notificationOops = 'assets/images/noti_oops.png';

  // ── My Booking ──────────────────────────────────────────────────────────
  /// Suitcase/phone hero of the empty booking segments (the "Opps!!"
  /// headline above it is rendered as text — it is not part of the image).
  static const String bookingOops = 'assets/images/oops.png';

  /// Purple icons of the action rows under a completed/cancelled stay.
  static const String bookingReview = 'assets/images/review.png';
  static const String bookingCall = 'assets/images/call.png';
}
