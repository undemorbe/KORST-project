import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display — large Cinzel titles (applied via GoogleFonts in theme)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57, fontWeight: FontWeight.w700,
    color: AppColors.onBackground, letterSpacing: 0.02,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45, fontWeight: FontWeight.w700,
    color: AppColors.onBackground, letterSpacing: 0.02,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w700,
    color: AppColors.onBackground, letterSpacing: 0.02,
  );

  // Headline — section Cinzel titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.onBackground, letterSpacing: 0.04,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.onBackground, letterSpacing: 0.04,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w600,
    color: AppColors.onBackground, letterSpacing: 0.04,
  );

  // Title — card titles (Cinzel in card, Inter elsewhere)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );

  // Body — Inter
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );
}
