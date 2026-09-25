import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Base
  // ---------------------------------------------------------------------------
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Soft shadows over light surfaces (search pill, details card, marker).
  static const Color black08 = Color(0x14000000);
  static const Color black10 = Color(0x1A000000);
  static const Color black26 = Color(0x42000000);

  /// Brand-adjacent near-black, used for dark surfaces and the splash screen.
  static const Color dark = Color(0xFF0B1327);
  static const Color transparent = Color(0x00000000);

  // ---------------------------------------------------------------------------
  // Gray (primary neutral scale)
  // ---------------------------------------------------------------------------
  static const Color gray25 = Color(0xFFFCFCFC);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF2F4F7);
  static const Color gray200 = Color(0xFFEAECF0);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray400 = Color(0xFF98A2B3);
  static const Color gray500 = Color(0xFF667085);
  static const Color gray600 = Color(0xFF475467);
  static const Color gray700 = Color(0xFF344054);
  static const Color gray800 = Color(0xFF1D2939);
  static const Color gray900 = Color(0xFF101828);

  // ---------------------------------------------------------------------------
  // Primary (violet)
  // ---------------------------------------------------------------------------
  static const Color primary25 = Color(0xFFFCFAFF);
  static const Color primary50 = Color(0xFFF9F5FF);
  static const Color primary100 = Color(0xFFF4EBFF);
  static const Color primary200 = Color(0xFFE9D7FE);
  static const Color primary300 = Color(0xFFD6BBFB);
  static const Color primary400 = Color(0xFFB692F6);
  static const Color primary500 = Color(0xFF9E77ED);
  static const Color primary600 = Color(0xFF7F56D9);
  static const Color primary700 = Color(0xFF6941C6);
  static const Color primary800 = Color(0xFF53389E);
  static const Color primary900 = Color(0xFF42307D);

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------
  static const Color error25 = Color(0xFFFFFBFA);
  static const Color error50 = Color(0xFFFEF3F2);
  static const Color error100 = Color(0xFFFEE4E2);
  static const Color error200 = Color(0xFFFECDCA);
  static const Color error300 = Color(0xFFFDA29B);
  static const Color error400 = Color(0xFFF97066);
  static const Color error500 = Color(0xFFF04438);
  static const Color error600 = Color(0xFFD92D20);
  static const Color error700 = Color(0xFFB42318);
  static const Color error800 = Color(0xFF912018);
  static const Color error900 = Color(0xFF7A271A);

  // ---------------------------------------------------------------------------
  // Success
  // ---------------------------------------------------------------------------
  static const Color success25 = Color(0xFFF6FEF9);
  static const Color success50 = Color(0xFFECFDF3);
  static const Color success100 = Color(0xFFD1FADF);
  static const Color success200 = Color(0xFFA6F4C5);
  static const Color success300 = Color(0xFF6CE9A6);
  static const Color success400 = Color(0xFF32D583);
  static const Color success500 = Color(0xFF12B76A);
  static const Color success600 = Color(0xFF039855);
  static const Color success700 = Color(0xFF027A48);
  static const Color success800 = Color(0xFF05603A);
  static const Color success900 = Color(0xFF054F31);

  // ---------------------------------------------------------------------------
  // Warning
  // ---------------------------------------------------------------------------
  static const Color warning25 = Color(0xFFFFFCF5);
  static const Color warning50 = Color(0xFFFFFAEB);
  static const Color warning100 = Color(0xFFFEF0C7);
  static const Color warning200 = Color(0xFFFEDF89);
  static const Color warning300 = Color(0xFFFEC84B);
  static const Color warning400 = Color(0xFFFDB022);
  static const Color warning500 = Color(0xFFF79009);
  static const Color warning600 = Color(0xFFDC6803);
  static const Color warning700 = Color(0xFFB54708);
  static const Color warning800 = Color(0xFF93370D);
  static const Color warning900 = Color(0xFF7A2E0E);

  // ---------------------------------------------------------------------------
  // Secondary — Gray Neutral
  // ---------------------------------------------------------------------------
  static const Color grayNeutral25 = Color(0xFFFCFCFD);
  static const Color grayNeutral50 = Color(0xFFF9FAFB);
  static const Color grayNeutral100 = Color(0xFFF3F4F6);
  static const Color grayNeutral200 = Color(0xFFE5E7EB);
  static const Color grayNeutral300 = Color(0xFFD2D6DB);
  static const Color grayNeutral400 = Color(0xFF9DA4AE);
  static const Color grayNeutral500 = Color(0xFF6C737F);
  static const Color grayNeutral600 = Color(0xFF4D5761);
  static const Color grayNeutral700 = Color(0xFF384250);
  static const Color grayNeutral800 = Color(0xFF1F2A37);
  static const Color grayNeutral900 = Color(0xFF111927);

  // ---------------------------------------------------------------------------
  // Secondary — Gray Blue
  // ---------------------------------------------------------------------------
  static const Color grayBlue25 = Color(0xFFFCFCFD);
  static const Color grayBlue50 = Color(0xFFF8F9FC);
  static const Color grayBlue100 = Color(0xFFEAECF5);
  static const Color grayBlue200 = Color(0xFFD5D9EB);
  static const Color grayBlue300 = Color(0xFFB3B8DB);
  static const Color grayBlue400 = Color(0xFF7177BC);
  static const Color grayBlue500 = Color(0xFF4E5BA6);
  static const Color grayBlue600 = Color(0xFF3E4784);
  static const Color grayBlue700 = Color(0xFF363F72);
  static const Color grayBlue800 = Color(0xFF293056);
  static const Color grayBlue900 = Color(0xFF101323);

  // ---------------------------------------------------------------------------
  // Secondary — Gray Cool
  // ---------------------------------------------------------------------------
  static const Color grayCool25 = Color(0xFFFCFCFD);
  static const Color grayCool50 = Color(0xFFF9F9FB);
  static const Color grayCool100 = Color(0xFFEFF1F5);
  static const Color grayCool200 = Color(0xFFDCDFEA);
  static const Color grayCool300 = Color(0xFFB9C0D4);
  static const Color grayCool400 = Color(0xFF7D89B0);
  static const Color grayCool500 = Color(0xFF5D6B98);
  static const Color grayCool600 = Color(0xFF4A5578);
  static const Color grayCool700 = Color(0xFF404968);
  static const Color grayCool800 = Color(0xFF30374F);
  static const Color grayCool900 = Color(0xFF111322);

  // ---------------------------------------------------------------------------
  // Secondary — Gray Modern
  // ---------------------------------------------------------------------------
  static const Color grayModern25 = Color(0xFFFCFCFD);
  static const Color grayModern50 = Color(0xFFF8FAFC);
  static const Color grayModern100 = Color(0xFFEEF2F6);
  static const Color grayModern200 = Color(0xFFE3E8EF);
  static const Color grayModern300 = Color(0xFFCDD5DF);
  static const Color grayModern400 = Color(0xFF9AA4B2);
  static const Color grayModern500 = Color(0xFF697586);
  static const Color grayModern600 = Color(0xFF4B5565);
  static const Color grayModern700 = Color(0xFF364152);
  static const Color grayModern800 = Color(0xFF202939);
  static const Color grayModern900 = Color(0xFF121926);

  // ---------------------------------------------------------------------------
  // Secondary — Gray True
  // ---------------------------------------------------------------------------
  static const Color grayTrue25 = Color(0xFFFCFCFD);
  static const Color grayTrue50 = Color(0xFFFAFAFA);
  static const Color grayTrue100 = Color(0xFFF5F5F5);
  static const Color grayTrue200 = Color(0xFFE5E5E5);
  static const Color grayTrue300 = Color(0xFFD6D6D6);
  static const Color grayTrue400 = Color(0xFFA3A3A3);
  static const Color grayTrue500 = Color(0xFF737373);
  static const Color grayTrue600 = Color(0xFF525252);
  static const Color grayTrue700 = Color(0xFF424242);
  static const Color grayTrue800 = Color(0xFF292929);
  static const Color grayTrue900 = Color(0xFF141414);

  // ---------------------------------------------------------------------------
  // Secondary — Gray Warm
  // ---------------------------------------------------------------------------
  static const Color grayWarm25 = Color(0xFFFCFCFD);
  static const Color grayWarm50 = Color(0xFFFAFAF9);
  static const Color grayWarm100 = Color(0xFFF5F5F4);
  static const Color grayWarm200 = Color(0xFFE7E5E4);
  static const Color grayWarm300 = Color(0xFFD7D3D0);
  static const Color grayWarm400 = Color(0xFFA9A29D);
  static const Color grayWarm500 = Color(0xFF79716B);
  static const Color grayWarm600 = Color(0xFF57534E);
  static const Color grayWarm700 = Color(0xFF44403C);
  static const Color grayWarm800 = Color(0xFF292524);
  static const Color grayWarm900 = Color(0xFF1C1917);

  // ---------------------------------------------------------------------------
  // Screen-specific illustration colors (location map canvas)
  //
  // The mock map on the location picker is drawn with a CustomPainter, so
  // these are the only hex values added outside the Figma Color page — kept
  // here so the "hex only in AppColors" rule still holds.
  // ---------------------------------------------------------------------------
  /// Land tint of the mock map.
  static const Color mapLand = Color(0xFFF1F2F5);

  /// City blocks / casing between the streets.
  static const Color mapBlock = Color(0xFFE4E7EC);

  /// Street surface.
  static const Color mapRoad = white;

  /// River / waterway crossing the map.
  static const Color mapWater = Color(0xFFC5DDF2);

  /// Small park patch.
  static const Color mapPark = Color(0xFFE7F5E9);

  /// Pin dropped at the map's center (amber, as designed).
  static const Color mapMarker = warning400;

  // ---------------------------------------------------------------------------
  // Semantic aliases — the only colors widgets should usually reach for.
  // Point a UI change here instead of hunting hex values through the UI layer.
  // ---------------------------------------------------------------------------

  /// Default screen background (light theme).
  static const Color background = gray50;

  /// Elevated surface: cards, sheets, dialogs.
  static const Color surface = white;

  /// Barely-tinted background (chips, skeletons, list highlights).
  static const Color surfaceMuted = gray25;

  /// Primary text on light surfaces.
  static const Color textPrimary = gray900;

  /// Secondary text: descriptions, supporting copy.
  static const Color textSecondary = gray700;

  /// Tertiary text: hints, timestamps, placeholders.
  static const Color textMuted = gray500;

  /// Text/icons on top of primary-colored surfaces.
  static const Color textOnPrimary = white;

  /// Default border & outline color.
  static const Color border = gray300;

  /// Hairline dividers inside cards and lists.
  static const Color divider = gray200;

  /// Brand / interactive color (buttons, links, selection).
  static const Color primary = primary600;

  /// Pressed / hover state of [primary].
  static const Color primaryPressed = primary700;

  /// Tinted container behind brand elements (badges, selected chips).
  static const Color primaryContainer = primary100;

  static const Color success = success500;
  static const Color successContainer = success50;
  static const Color warning = warning500;
  static const Color warningContainer = warning50;
  static const Color error = error500;
  static const Color errorContainer = error50;

  // Dark theme counterparts.
  static const Color darkBackground = dark;
  static const Color darkSurface = grayNeutral800;
  static const Color darkTextPrimary = white;
  static const Color darkTextSecondary = grayNeutral300;
  static const Color darkBorder = grayNeutral700;
}
