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
