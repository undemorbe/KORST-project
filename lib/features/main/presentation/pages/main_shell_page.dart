import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import '../../../../core/di/injection_container.dart';
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
  OverlayEntry? _bannerEntry;
  ReactionDisposer? _reactionDisposer;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
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
    _bannerEntry?.remove();
    _bannerEntry = null;
    super.dispose();
  }

  void _showBanner(IncomingMessageInfo info) {
    _bannerEntry?.remove();
    _bannerEntry = null;
    _dismissTimer?.cancel();

    _bannerEntry = OverlayEntry(
      builder: (ctx) => _IncomingBanner(
        info: info,
        onTap: () {
          _dismissBanner();
          _goBranch(2);
        },
        onDismiss: _dismissBanner,
      ),
    );

    Overlay.of(context).insert(_bannerEntry!);

    _dismissTimer = Timer(const Duration(seconds: 4), _dismissBanner);
  }

  void _dismissBanner() {
    _bannerEntry?.remove();
    _bannerEntry = null;
    _dismissTimer?.cancel();
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
      body: widget.navigationShell,
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

class _IncomingBanner extends StatefulWidget {
  final IncomingMessageInfo info;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _IncomingBanner({
    required this.info,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_IncomingBanner> createState() => _IncomingBannerState();
}

class _IncomingBannerState extends State<_IncomingBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: topPad + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border(
                    left: BorderSide(color: cs.primary, width: 4),
                    top: BorderSide(color: cs.outlineVariant),
                    right: BorderSide(color: cs.outlineVariant),
                    bottom: BorderSide(color: cs.outlineVariant),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.info.senderName,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                          ),
                          if (widget.info.cardName.isNotEmpty)
                            Text(
                              widget.info.cardName,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            widget.info.text,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: Icon(
                        Icons.close,
                        color: cs.onSurfaceVariant,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
