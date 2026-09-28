/// Housely design tokens — spacing, radii, sizes and motion.
///
/// Keep magic numbers out of the widget tree: a designer changing the spacing
/// scale should only have to touch this file.
abstract final class AppDimensions {
  AppDimensions._();

  // ---------------------------------------------------------------------------
  // Spacing (4pt grid)
  // ---------------------------------------------------------------------------
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  /// Common screen gutter.
  static const double pagePadding = space20;

  /// Notification inbox gutter — this screen's mockup runs a 25dp content
  /// margin (leading circles/headers at x=25, hairlines ending at x=365),
  /// measured off the export rather than the usual 20dp page padding.
  static const double pagePaddingWide = 25;

  /// Notification row leading circle (photo/bell/person) — measured 38dp off
  /// the mockup, which puts the text column at 25 + 38 + 12 = 75dp.
  static const double notificationLeading = 38;

  // ---------------------------------------------------------------------------
  // Radii
  // ---------------------------------------------------------------------------
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;

  /// Hero media corners — promo banner + featured Home card. Measured from the
  /// kit's `Banner_1`/`Banner_2` exports (35px on a 448px-wide card ≈ 18dp).
  static const double radiusMedia = 18;
  static const double radius2xl = 20;
  static const double radiusFull = 999;

  // ---------------------------------------------------------------------------
  // Sizes
  // ---------------------------------------------------------------------------
  static const double borderWidth = 1;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double buttonHeight = 48;

  /// Taller primary CTA (the details screen's "Rent now").
  static const double buttonHeightLarge = 56;
  static const double inputHeight = 48;
  static const double appBarHeight = 56;
  static const double bottomNavBarHeight = 72;
  static const double propertyCardImageHeight = 200;

  // ---------------------------------------------------------------------------
  // Motion
  // ---------------------------------------------------------------------------
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Duration networkTimeout = Duration(seconds: 20);
}
