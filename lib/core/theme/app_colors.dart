import 'package:flutter/material.dart';

class AppColors {
  // Modern Indigo/Violet palette
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryContainer = Color(0xFFF3E8FF);
  static const Color onSecondaryContainer = Color(0xFF5B21B6);
  static const Color tertiary = Color(0xFFEC4899);
  static const Color tertiaryContainer = Color(0xFFFCE7F3);
  static const Color onTertiaryContainer = Color(0xFF9D174D);

  // Light theme
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color onError = Colors.white;
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F172A); // Very dark slate
  static const Color darkSurface = Color(0xFF1E293B); // Deep slate for cards
  static const Color darkSurfaceVariant = Color(0xFF334155); // Lighter slate for inputs
  static const Color darkOnBackground = Color(0xFFF8FAFC); // Almost white
  static const Color darkOnSurface = Color(0xFFF1F5F9); // Slightly muted white
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8); // Slate gray for secondary text
  static const Color darkOutline = Color(0xFF475569); // Border color
  static const Color darkOutlineVariant = Color(0xFF334155); // Muted border

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> secondaryGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
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
