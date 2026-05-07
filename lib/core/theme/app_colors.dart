import 'package:flutter/material.dart';

class AppColors {
  // Editorial taskboard palette
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF134E4A);
  static const Color secondary = Color(0xFFDC2626);
  static const Color secondaryContainer = Color(0xFFFEE2E2);
  static const Color onSecondaryContainer = Color(0xFF7F1D1D);
  static const Color tertiary = Color(0xFFCA8A04);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFF713F12);

  // Light theme
  static const Color background = Color(0xFFF6F7F4);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFE9ECE5);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color onError = Colors.white;
  static const Color outline = Color(0xFFD6DBD2);
  static const Color outlineVariant = Color(0xFFC6CDC1);

  // Dark theme
  static const Color darkBackground = Color(0xFF101412);
  static const Color darkSurface = Color(0xFF181D1A);
  static const Color darkSurfaceVariant = Color(0xFF252C28);
  static const Color darkOnBackground = Color(0xFFF4F7F2);
  static const Color darkOnSurface = Color(0xFFF4F7F2);
  static const Color darkOnSurfaceVariant = Color(0xFFBDC8BE);
  static const Color darkOutline = Color(0xFF46514A);
  static const Color darkOutlineVariant = Color(0xFF303A34);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0F766E),
    Color(0xFF14B8A6),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFFDC2626),
    Color(0xFFF59E0B),
  ];
  static const List<Color> glassLight = [Color(0x80FFFFFF), Color(0x40FFFFFF)];
  static const List<Color> glassDark = [Color(0x401E293B), Color(0x200F172A)];

  // Extended success/info/warning colors
  static const Color success = Color(0xFF22C55E);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF166534);

  static const Color info = Color(0xFF3B82F6);
  static const Color onInfo = Colors.white;
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E40AF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  // Shadow colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // Rating colors
  static const Color ratingStar = Color(0xFFF59E0B);
  static const Color ratingStarEmpty = Color(0xFFE5E7EB);

  // Divider
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
}
