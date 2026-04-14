import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/glass.dart';

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(extendBodyBehindAppBar: true,
      extendBody: true, // Allow content to flow behind bottom nav
      body: navigationShell,
      bottomNavigationBar: Glass(
        borderRadius: BorderRadius.zero,
        blurSigma: 24,
        opacity: 0.85,
        color: colors.surface.withValues(alpha: 0.85),
        borderWidth: 0,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: colors.primaryContainer.withValues(alpha: 0.6),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  icon: const Icon(Icons.settings_outlined, size: 24),
                  selectedIcon: const Icon(Icons.settings_rounded, size: 24),
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
