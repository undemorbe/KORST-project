import 'package:flutter/material.dart';

class AppColors {
  // Plague & Gold — dark foundation
  static const Color background    = Color(0xFF080604);
  static const Color surface       = Color(0xFF12100A);
  static const Color surfaceCard   = Color(0xFF1C1810); // gradient start
  static const Color surfaceCardEnd= Color(0xFF12100A); // gradient end

  // Borders & dividers
  static const Color border        = Color(0xFF5A4820);
  static const Color borderSubtle  = Color(0xFF3A2E18);
  static const Color insetHighlight= Color(0xFF6A5028); // top-edge shimmer

  // Gold accent
  static const Color primary       = Color(0xFFC49A22);
  static const Color primaryLight  = Color(0xFFD4AA55);
  static const Color onPrimary     = Color(0xFF080604);

  // Text
  static const Color onBackground  = Color(0xFFE8D4A0); // parchment
  static const Color onSurface     = Color(0xFFC8B890);
  static const Color muted         = Color(0xFF7A6A3A);
  static const Color mutedDark     = Color(0xFF5A4A28);

  // Semantic
  static const Color error         = Color(0xFFAA4444);
  static const Color onError       = Color(0xFFFFFFFF);
  static const Color success       = Color(0xFF6AAA6A);
  static const Color onSuccess     = Color(0xFF080604);
  static const Color warning       = Color(0xFFCCAA44);

  // Glow
  static const Color goldGlow      = Color(0x12C49A22); // box-shadow
  static const Color goldGlowText  = Color(0x50C49A22); // text-shadow equivalent

  // Rating
  static const Color ratingStar    = Color(0xFFC49A22);

  // Legacy aliases used by existing code — kept for compatibility
  static const Color darkBackground      = background;
  static const Color darkSurface         = surface;
  static const Color darkSurfaceVariant  = Color(0xFF1E1A09);
  static const Color darkOnBackground    = onBackground;
  static const Color darkOnSurface       = onSurface;
  static const Color darkOnSurfaceVariant= muted;
  static const Color darkOutline         = border;
  static const Color darkOutlineVariant  = borderSubtle;
  static const Color dividerDark         = borderSubtle;

  // Material3 ColorScheme aliases — map to Plague & Gold equivalents
  // (used by current app_theme.dart; can be removed after theme is replaced)
  static const Color primaryContainer    = Color(0xFF2A2008);
  static const Color onPrimaryContainer  = primaryLight;
  static const Color secondary           = warning;
  static const Color onSecondary         = onPrimary;
  static const Color secondaryContainer  = Color(0xFF1E1A09);
  static const Color onSecondaryContainer= warning;
  static const Color tertiary            = success;
  static const Color tertiaryContainer   = Color(0xFF0D1A0E);
  static const Color onTertiaryContainer = success;
  static const Color outline             = border;
  static const Color outlineVariant      = borderSubtle;
  static const Color onSurfaceVariant    = muted;
  static const Color surfaceVariant      = Color(0xFF1E1A09);
  static const Color shadowLight         = Color(0x1F000000);
  static const Color shadowDark          = Color(0x3F000000);

  // Light theme aliases (point to same dark values — dark-only app)
  static const Color lightBackground = background;
  static const Color lightSurface    = surface;
}
