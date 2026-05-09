# Dark Fantasy Redesign — Plague & Gold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current editorial green/teal theme with a Plague & Gold dark fantasy aesthetic — near-black backgrounds, tarnished gold accents, Cinzel serif headings, relic-panel cards with subtle gold glow.

**Architecture:** Dark-only theme. Foundation changes flow top-down: colors → text styles → theme → surface widgets → feature widgets. `ServiceEntity` gains an optional `status` field and `ServiceStore` gains a `createReply` action for the reply flow from `POST /cards/create-reply`.

**Tech Stack:** Flutter/Dart, MobX, Google Fonts (Cinzel already available via `google_fonts` package), Dio/ApiClient for reply endpoint.

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `lib/core/theme/app_colors.dart` | Modify | Plague & Gold palette |
| `lib/core/theme/app_text_styles.dart` | Modify | Cinzel for display/headline text styles |
| `lib/core/theme/app_theme.dart` | Modify | Dark-only ColorScheme + component themes |
| `lib/core/theme/animated_gradient_background.dart` | Modify | Slow dark gradient (#080604 family) |
| `lib/core/widgets/glass.dart` | Modify | GlassCard/GlassAppBar → relic-panel style |
| `lib/core/widgets/app_layout.dart` | Modify | AppPageHeader title → Cinzel |
| `lib/features/main/presentation/pages/main_shell_page.dart` | Modify | Standard nav labels + gold active style |
| `lib/features/services/domain/entities/service_entity.dart` | Modify | Add optional `status` field |
| `lib/core/api/api_constants.dart` | Modify | Add `createReply` endpoint constant |
| `lib/features/services/presentation/store/service_store.dart` | Modify | Add `createReply(cardId)` action |
| `lib/features/services/presentation/widgets/service_card.dart` | Modify | Relic-panel layout + reply button + status badge |
| `lib/features/services/presentation/widgets/service_card_shimmer.dart` | Modify | Dark shimmer base colors |
| `lib/features/services/presentation/pages/services_home_page.dart` | Modify | Search + chips dark styling |
| `lib/features/settings/presentation/store/settings_store.dart` | Modify | Default themeMode → ThemeMode.dark |

---

### Task 1: Plague & Gold Color Palette

**Files:**
- Modify: `lib/core/theme/app_colors.dart`

- [ ] **Step 1: Replace app_colors.dart**

```dart
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
}
```

- [ ] **Step 2: Verify**

```bash
cd /Users/dolbobob/Programming/FlutterApps/korst && flutter analyze lib/core/theme/app_colors.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_colors.dart
git commit -m "design: plague & gold color palette"
```

---

### Task 2: Cinzel Text Styles

**Files:**
- Modify: `lib/core/theme/app_text_styles.dart`

- [ ] **Step 1: Update text styles to reference new palette**

The key change: `display*` and `headline*` styles will be overridden with Cinzel in the theme's `textTheme`. The `AppTextStyles` class provides base sizes; fonts are applied in `AppTheme`. Update color references to new palette:

```dart
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
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/core/theme/app_text_styles.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_text_styles.dart
git commit -m "design: update text style colors for plague & gold"
```

---

### Task 3: Dark-Only Theme with Cinzel

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Replace app_theme.dart**

```dart
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
```

- [ ] **Step 2: Verify compile**

```bash
flutter analyze lib/core/theme/app_theme.dart
```

Expected: No errors (warnings about deprecated APIs are acceptable).

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "design: dark-only plague & gold theme with Cinzel"
```

---

### Task 4: Animated Background

**Files:**
- Modify: `lib/core/theme/animated_gradient_background.dart`

- [ ] **Step 1: Replace with Plague & Gold dark gradient**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _buildGradient(double t) {
    final drift = math.sin(t * math.pi * 2) * 0.12;
    return LinearGradient(
      begin: Alignment(-1.0, -0.8 + drift),
      end: Alignment(1.0, 0.8 - drift),
      colors: const [
        Color(0xFF080604),
        Color(0xFF0F0C08),
        Color(0xFF14100A),
        Color(0xFF080604),
      ],
      stops: [0.0, 0.35 + drift * 0.1, 0.70 + drift * 0.05, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => DecoratedBox(
        decoration: BoxDecoration(gradient: _buildGradient(_controller.value)),
        child: widget.child,
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/core/theme/animated_gradient_background.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/animated_gradient_background.dart
git commit -m "design: dark plague & gold animated background"
```

---

### Task 5: Relic-Panel Glass Widgets

**Files:**
- Modify: `lib/core/widgets/glass.dart`

- [ ] **Step 1: Update Glass, GlassCard, GlassAppBar for Plague & Gold**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double opacity;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  const Glass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.blurSigma = 10,
    this.opacity = 0.92,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.surface.withValues(alpha: opacity);
    final border = borderColor ?? AppColors.border;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: base,
            borderRadius: borderRadius,
            border: Border.all(color: border, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Relic-panel card: gradient fill + gold border + gold glow + inset highlight.
class GlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final Color? color;

  const GlassCard({
    super.key,
    this.child,
    this.margin,
    this.clipBehavior = Clip.none,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child ?? const SizedBox.shrink();
    final radius = BorderRadius.circular(8);

    if (clipBehavior != Clip.none) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color ?? AppColors.surfaceCard,
              color != null
                  ? color!.withValues(alpha: 0.85)
                  : AppColors.surfaceCardEnd,
            ],
          ),
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.goldGlow, blurRadius: 16, spreadRadius: 0),
            BoxShadow(
              color: Color(0xFF6A5028),
              offset: Offset(0, -1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.bottom,
    this.backgroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        AppColors.surface.withValues(alpha: 0.88);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            border: const Border(
              bottom: BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: centerTitle,
            bottom: bottom,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/core/widgets/glass.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/glass.dart
git commit -m "design: relic-panel glass widgets with gold border and glow"
```

---

### Task 6: App Layout — Cinzel Page Headers

**Files:**
- Modify: `lib/core/widgets/app_layout.dart`

- [ ] **Step 1: Update AppPageHeader to use Cinzel title style**

In `AppPageHeader.build`, change the title `Text` widget's style:

```dart
// Find this block in AppPageHeader (around line 44–55):
Text(
  title,
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.w900,
    height: 1.02,
  ),
),
```

Replace with:

```dart
Text(
  title,
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.w700,
    height: 1.02,
    color: AppColors.primaryLight,
    letterSpacing: 0.06,
  ),
),
```

Add import at top of file if not present:
```dart
import '../theme/app_colors.dart';
```

Also update the icon container in `AppPageHeader`:
```dart
// Find:
decoration: BoxDecoration(
  color: colors.primary,
  borderRadius: BorderRadius.circular(8),
),
// Replace with:
decoration: BoxDecoration(
  color: AppColors.primary.withValues(alpha: 0.15),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: AppColors.border),
),
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/core/widgets/app_layout.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/app_layout.dart
git commit -m "design: Cinzel headings and gold icon in AppPageHeader"
```

---

### Task 7: Bottom Navigation — Standard Labels + Gold Style

**Files:**
- Modify: `lib/features/main/presentation/pages/main_shell_page.dart`

- [ ] **Step 1: Replace MainShellPage**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/theme/app_colors.dart';

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Glass(
          borderRadius: BorderRadius.circular(12),
          blurSigma: 20,
          color: AppColors.surface.withValues(alpha: 0.94),
          borderColor: AppColors.border,
          child: SizedBox(
            height: 68,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined, size: 24),
                  selectedIcon: const Icon(Icons.home_rounded, size: 24),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.favorite_outline, size: 24),
                  selectedIcon: const Icon(Icons.favorite_rounded, size: 24),
                  label: l10n.navFavorites,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline, size: 24),
                  selectedIcon: const Icon(Icons.chat_bubble_rounded, size: 24),
                  label: l10n.navChats,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline, size: 24),
                  selectedIcon: const Icon(Icons.person_rounded, size: 24),
                  label: l10n.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/main/presentation/pages/main_shell_page.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/main/presentation/pages/main_shell_page.dart
git commit -m "design: standard nav labels, gold active style"
```

---

### Task 8: Add `status` Field to ServiceEntity

**Files:**
- Modify: `lib/features/services/domain/entities/service_entity.dart`

The `GET /user/me` response includes `status` per card (`active`, `in-progress`, `completed`, `closed`). `GET /cards/get-cards` doesn't include status. Make it optional.

- [ ] **Step 1: Add `status` field**

Add to class fields (after `imageUrl`):
```dart
final String? status; // active | in-progress | completed | closed — present in /user/me only
```

Add to constructor:
```dart
this.status,
```

Add to `fromJson`:
```dart
status: json['status'] as String?,
```

Add to `toJson`:
```dart
'status': status,
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/services/domain/entities/service_entity.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/services/domain/entities/service_entity.dart
git commit -m "feat: optional status field on ServiceEntity from /user/me"
```

---

### Task 9: Expose `replyError` in ServiceStore

**Files:**
- Modify: `lib/features/services/presentation/store/service_store.dart`

`ApiConstants.cardsCreateReply`, `EnvConfig.cardsCreateReply`, and `ServiceStore.createReply(cardId)` already exist. The store just needs an observable `replyError` field so the card widget can surface errors.

- [ ] **Step 1: Check existing createReply implementation**

```bash
grep -n "createReply\|replyError" lib/features/services/presentation/store/service_store.dart
```

If `replyError` observable already exists, skip to Step 4.

- [ ] **Step 2: Add replyError observable (if missing)**

In `service_store.dart`, add near other `@observable` fields:

```dart
@observable
String? replyError;
```

Update the existing `createReply` method to set it:

```dart
@action
Future<void> createReply(String cardId) async {
  replyError = null;
  try {
    await _serviceRepository.createReply(cardId);
  } catch (e) {
    replyError = e.toString();
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: completes without errors.

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/services/presentation/store/
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/services/presentation/store/service_store.dart \
  lib/features/services/presentation/store/service_store.g.dart
git commit -m "feat: replyError observable in ServiceStore"
```

---

### Task 10: Service Card — Relic Panel + Reply Button + Status Badge

**Files:**
- Modify: `lib/features/services/presentation/widgets/service_card.dart`

The current card is a `Material` + `InkWell` layout. Replace with a relic-panel `DecoratedBox` + `GestureDetector`. Keep the scale animation.

- [ ] **Step 1: Replace service_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/service_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../store/service_store.dart';

class ServiceCard extends StatefulWidget {
  final ServiceEntity service;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final String? heroTag;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _authorName {
    final author = widget.service.author;
    final me = sl<AuthStore>().userProfile;
    final l10n = AppLocalizations.of(context)!;
    if (author == null) return 'Unknown';
    final isMe = author.uid.isNotEmpty && author.uid == me?.uid;
    if (isMe) return l10n.serviceYou;
    final full = '${author.name} ${author.surname ?? ''}'.trim();
    return full.isEmpty ? 'Unknown' : full;
  }

  double get _rating {
    double? toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }
    final author = widget.service.author;
    for (final v in [
      author?.contacts['rating'],
      author?.contacts['rate'],
      widget.service.rating,
    ]) {
      final d = toDouble(v);
      if (d != null) return d;
    }
    return 0.0;
  }

  bool get _isMyCard {
    final me = sl<AuthStore>().userProfile;
    final author = widget.service.author;
    return author != null &&
        author.uid.isNotEmpty &&
        author.uid == (me?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroTag = widget.heroTag ?? 'service-image-${widget.service.id}';
    final authorPhotoUrl = widget.service.author?.photoUrl;
    final avatarLetter =
        (_authorName.trim().isNotEmpty ? _authorName.trim()[0] : '?')
            .toUpperCase();
    final priceText =
        '${widget.service.price.toStringAsFixed(0)} ${widget.service.currency}';
    final status = widget.service.status;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceCard, AppColors.surfaceCardEnd],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.goldGlow,
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (widget.service.imageUrl.isNotEmpty &&
                    !widget.service.imageUrl.contains('placehold'))
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.service.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Title row + favourite
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.service.title,
                              style: GoogleFonts.cinzel(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onBackground,
                                letterSpacing: 0.04,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: l10n.favoritesTitle,
                              icon: Icon(
                                widget.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: widget.isFavorite
                                    ? AppColors.error
                                    : AppColors.mutedDark,
                              ),
                              onPressed: widget.onFavoriteToggle,
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (widget.service.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.service.description.trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Price + type badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            priceText,
                            style: GoogleFonts.cinzel(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const Spacer(),
                          if (widget.service.type.isNotEmpty)
                            _TypeBadge(type: widget.service.type),
                          if (status != null) ...[
                            const SizedBox(width: 6),
                            _StatusBadge(status: status),
                          ],
                        ],
                      ),

                      // Tags
                      if (widget.service.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.service.tags.take(3).map((tag) {
                            return _Tag(label: tag);
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Author row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.darkSurfaceVariant,
                            backgroundImage: (authorPhotoUrl != null &&
                                    authorPhotoUrl.isNotEmpty)
                                ? CachedNetworkImageProvider(authorPhotoUrl)
                                : null,
                            child: (authorPhotoUrl == null ||
                                    authorPhotoUrl.isEmpty)
                                ? Text(
                                    avatarLetter,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_rating > 0) ...[
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.ratingStar),
                            const SizedBox(width: 2),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              color: AppColors.mutedDark, size: 18),
                        ],
                      ),

                      // Reply button — visible when active + not my card
                      if (!_isMyCard && (status == null || status == 'active'))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _onReply(context),
                              child: Text(
                                'Откликнуться',
                                style: GoogleFonts.cinzel(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.06,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onReply(BuildContext context) async {
    final store = sl<ServiceStore>();
    await store.createReply(widget.service.id);
    if (!mounted) return;
    final err = store.replyError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? 'Отклик отправлен' : 'Ошибка: $err',
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        type,
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  static const _map = {
    'active':               (Color(0xFFC49A22), 'Активно'),
    'in-progress':          (Color(0xFFCCAA44), 'В работе'),
    'completed':            (Color(0xFF6AAA6A), 'Завершено'),
    'closed':               (Color(0xFFAA4444), 'Закрыто'),
    'closed-with-bad-result':(Color(0xFFAA4444), 'Закрыто'),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _map[status] ?? (AppColors.muted, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/services/presentation/widgets/service_card.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/services/presentation/widgets/service_card.dart
git commit -m "design: relic-panel service card with reply button and status badge"
```

---

### Task 11: Service Card Shimmer — Dark Colors

**Files:**
- Modify: `lib/features/services/presentation/widgets/service_card_shimmer.dart`

- [ ] **Step 1: Update shimmer base and glow colors**

Find `_ShimmerBlockState.build` in `service_card_shimmer.dart`. Replace the color variables:

```dart
// Replace these lines:
final isDark = Theme.of(context).brightness == Brightness.dark;
final base = isDark ? const Color(0xFF1D2128) : const Color(0xFFE6E9EF);
final glowA = isDark ? const Color(0xFF303745) : const Color(0xFFF5F7FC);
final glowB = isDark ? const Color(0xFF3B4456) : const Color(0xFFFFFFFF);

// With:
const base  = Color(0xFF1A1608);
const glowA = Color(0xFF2A2010);
const glowB = Color(0xFF3A3018);
```

Also update `ServiceCardShimmer.build` — replace the `Glass` wrapper with a `DecoratedBox` matching the relic panel:

```dart
@override
Widget build(BuildContext context) {
  const radius = BorderRadius.all(Radius.circular(8));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1810), Color(0xFF12100A)],
        ),
        borderRadius: radius,
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF3A2E18))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            child: _ShimmerBlock(height: 140, width: double.infinity, borderRadius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ShimmerBlock(height: 16, width: double.infinity, borderRadius: 4),
                const SizedBox(height: 8),
                const _ShimmerBlock(height: 12, width: 160, borderRadius: 4),
                const SizedBox(height: 12),
                const _ShimmerBlock(height: 14, width: 100, borderRadius: 4),
                const SizedBox(height: 12),
                Row(children: [
                  const _ShimmerBlock(height: 28, width: 28, borderRadius: 14),
                  const SizedBox(width: 8),
                  const _ShimmerBlock(height: 12, width: 100, borderRadius: 4),
                ]),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/services/presentation/widgets/service_card_shimmer.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/services/presentation/widgets/service_card_shimmer.dart
git commit -m "design: dark shimmer matching relic panel card"
```

---

### Task 12: Services Home Page — Dark Search & Chips

**Files:**
- Modify: `lib/features/services/presentation/pages/services_home_page.dart`

- [ ] **Step 1: Update category chip builder**

Find `_buildCategoryChip` method and replace it:

```dart
Widget _buildCategoryChip(
  BuildContext context,
  String label,
  ServiceCategory? category,
) {
  final isSelected = _store.selectedCategory == category;
  return GestureDetector(
    onTap: () => _store.setCategory(category),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.15)
            : const Color(0xFF16130A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.border : AppColors.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.muted,
        ),
      ),
    ),
  );
}
```

Add import at top if missing:
```dart
import '../../../../core/theme/app_colors.dart';
```

- [ ] **Step 2: Update the category chips container background** — find the `SliverPersistentHeader` delegate's `Container` and change its color:

```dart
// Find:
color: Theme.of(context).scaffoldBackgroundColor,
// Replace with:
color: Colors.transparent,
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/features/services/presentation/pages/services_home_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/services/presentation/pages/services_home_page.dart
git commit -m "design: dark chip styling in services home"
```

---

### Task 13: Force Dark Theme Default

**Files:**
- Modify: `lib/features/settings/presentation/store/settings_store.dart`

- [ ] **Step 1: Change default themeMode to dark**

Find:
```dart
ThemeMode themeMode = ThemeMode.system;
```

Replace with:
```dart
ThemeMode themeMode = ThemeMode.dark;
```

- [ ] **Step 2: Verify full project**

```bash
flutter analyze
```

Expected: No errors. Fix any warnings about missing imports or renamed constants before committing.

- [ ] **Step 3: Final build check**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: `Built build/app/outputs/...` — no compile errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/presentation/store/settings_store.dart
git commit -m "design: default to dark theme"
```

---

### Task 14: Final Integration Commit

- [ ] **Step 1: Run full analysis**

```bash
flutter analyze
```

Fix any remaining issues.

- [ ] **Step 2: Tag the redesign**

```bash
git log --oneline -15
```

Confirm all 13 previous commits are present.

- [ ] **Step 3: Final commit if any leftover changes**

```bash
git status
# If anything unstaged:
git add -p
git commit -m "design: dark fantasy plague & gold — final cleanup"
```
