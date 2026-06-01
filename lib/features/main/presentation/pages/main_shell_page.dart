import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../messenger/presentation/store/messenger_store.dart';

class MainShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with SingleTickerProviderStateMixin {
  final MessengerStore _store = sl<MessengerStore>();
  ReactionDisposer? _reactionDisposer;
  Timer? _dismissTimer;
  IncomingMessageInfo? _currentInfo;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _reactionDisposer = reaction(
      (_) => _store.incomingMessage,
      (IncomingMessageInfo? info) {
        if (info != null && mounted) {
          _showBanner(info);
        }
      },
    );
  }

  @override
  void dispose() {
    _reactionDisposer?.call();
    _dismissTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _showBanner(IncomingMessageInfo info) {
    _dismissTimer?.cancel();
    setState(() => _currentInfo = info);
    _fadeCtrl.forward(from: 0);
    _dismissTimer = Timer(const Duration(seconds: 4), _dismissBanner);
  }

  void _dismissBanner() {
    _dismissTimer?.cancel();
    _fadeCtrl.reverse().then((_) {
      if (mounted) setState(() => _currentInfo = null);
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          widget.navigationShell,
          if (_currentInfo != null)
            FadeTransition(
              opacity: _fadeAnim,
              child: _NotificationBar(
                info: _currentInfo!,
                onTap: () {
                  _dismissBanner();
                  _goBranch(2);
                },
                onDismiss: _dismissBanner,
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Glass(
          borderRadius: BorderRadius.circular(12),
          blurSigma: 20,
          color: cs.surface.withValues(alpha: 0.94),
          borderColor: cs.outline,
          child: SizedBox(
            height: 68,
            child: Observer(
              builder: (_) {
                final unread = _store.totalUnreadCount;
                return NavigationBar(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: cs.primary.withValues(alpha: 0.15),
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
                      selectedIcon:
                          const Icon(Icons.favorite_rounded, size: 24),
                      label: l10n.navFavorites,
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: cs.primary,
                        textColor: cs.onPrimary,
                        child: const Icon(Icons.chat_bubble_outline, size: 24),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: cs.primary,
                        textColor: cs.onPrimary,
                        child: const Icon(Icons.chat_bubble_rounded, size: 24),
                      ),
                      label: l10n.navChats,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline, size: 24),
                      selectedIcon: const Icon(Icons.person_rounded, size: 24),
                      label: l10n.navSettings,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notification bar — fades in/out at top of screen ─────────────────────────

class _NotificationBar extends StatelessWidget {
  final IncomingMessageInfo info;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBar({
    required this.info,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bannerBg =
        isDark ? const Color(0xFF332B12) : AppColors.lSurfaceCard;
    final textPrimary =
        isDark ? AppColors.onBackground : AppColors.lOnSurface;
    final textSecondary = isDark
        ? AppColors.muted
        : AppColors.lOnSurface.withValues(alpha: 0.65);

    return Material(
      color: bannerBg,
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 8, 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.senderName,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (info.cardName.isNotEmpty)
                      Text(
                        info.cardName,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      info.text,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: textSecondary,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
