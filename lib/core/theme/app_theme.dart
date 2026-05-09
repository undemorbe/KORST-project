import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static final ThemeData darkTheme = _buildDarkTheme();

  // Kept for backwards compat — callers using lightTheme get dark too
  static final ThemeData lightTheme = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final TextTheme baseText = ThemeData.dark().textTheme;

    // Cinzel for display/headline, Inter for everything else
    final TextTheme cinzelHeadlines = GoogleFonts.cinzelTextTheme(
      baseText.copyWith(
        displayLarge:  AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall:  AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium:AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge:    AppTextStyles.titleLarge,
      ),
    );
    final TextTheme interBody = GoogleFonts.interTextTheme(
      cinzelHeadlines.copyWith(
        titleMedium: AppTextStyles.titleMedium,
        titleSmall:  AppTextStyles.titleSmall,
        bodyLarge:   AppTextStyles.bodyLarge,
        bodyMedium:  AppTextStyles.bodyMedium,
        bodySmall:   AppTextStyles.bodySmall,
        labelLarge:  AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall:  AppTextStyles.labelSmall,
      ),
    ).apply(
      bodyColor:    AppColors.onSurface,
      displayColor: AppColors.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:                AppColors.primary,
        onPrimary:              AppColors.onPrimary,
        primaryContainer:       Color(0xFF2A2008),
        onPrimaryContainer:     AppColors.primaryLight,
        secondary:              AppColors.warning,
        onSecondary:            AppColors.onPrimary,
        secondaryContainer:     Color(0xFF1E1A09),
        onSecondaryContainer:   AppColors.warning,
        tertiary:               AppColors.success,
        tertiaryContainer:      Color(0xFF0D1A0E),
        onTertiaryContainer:    AppColors.success,
        surface:                AppColors.surface,
        surfaceContainerHighest:AppColors.darkSurfaceVariant,
        onSurface:              AppColors.onSurface,
        onSurfaceVariant:       AppColors.muted,
        error:                  AppColors.error,
        onError:                AppColors.onError,
        outline:                AppColors.border,
        outlineVariant:         AppColors.borderSubtle,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,

      textTheme: interBody,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.primaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.16,
        ),
        iconTheme: const IconThemeData(color: AppColors.muted),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceCard,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.mutedDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.primary : AppColors.mutedDark,
          );
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          side: BorderSide(color: AppColors.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 16,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF16130A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.mutedDark, fontSize: 14),
        prefixIconColor: AppColors.mutedDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface),
          elevation: WidgetStateProperty.all(8),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
