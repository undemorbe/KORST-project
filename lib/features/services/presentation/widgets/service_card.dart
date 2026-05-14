import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/service_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../../messenger/domain/entities/chat_entity.dart';
import '../../../messenger/presentation/store/messenger_store.dart';
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

class _ServiceCardState extends State<ServiceCard> {

  String _buildAuthorName(BuildContext context) {
    final author = widget.service.author;
    final me = sl<AuthStore>().userProfile;
    final l10n = AppLocalizations.of(context)!;
    if (author == null) return 'Unknown';
    final isMe = author.uid.isNotEmpty && author.uid == (me?.uid ?? '');
    if (isMe) return l10n.serviceYou;
    final full = '${author.name} ${author.surname ?? ''}'.trim();
    return full.isEmpty ? 'Unknown' : full;
  }

  double _extractRating() {
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
    if (author == null || me == null) return false;

    // UID match
    if (author.uid.isNotEmpty && me.uid.isNotEmpty && author.uid == me.uid) {
      return true;
    }

    // Phone fallback (server may return phone as UID)
    final cleanAuthor = author.phone.replaceAll(RegExp(r'\D'), '');
    final cleanMe = me.phone.replaceAll(RegExp(r'\D'), '');
    final cleanAuthorUid = author.uid.replaceAll(RegExp(r'\D'), '');
    final cleanMeUid = me.uid.replaceAll(RegExp(r'\D'), '');

    if (cleanAuthor.length >= 7 && cleanMe.length >= 7 &&
        cleanAuthor == cleanMe) { return true; }
    if (cleanAuthorUid.length >= 7 && cleanMe.length >= 7 &&
        cleanAuthorUid == cleanMe) { return true; }
    if (cleanAuthor.length >= 7 && cleanMeUid.length >= 7 &&
        cleanAuthor == cleanMeUid) { return true; }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroTag = widget.heroTag ?? 'service-image-${widget.service.id}';
    final authorName = _buildAuthorName(context);
    final authorPhotoUrl = widget.service.author?.photoUrl;
    final avatarLetter =
        (authorName.trim().isNotEmpty ? authorName.trim()[0] : '?')
            .toUpperCase();
    final priceText =
        '${widget.service.price.toStringAsFixed(0)} ${widget.service.currency}';
    final status = widget.service.status;
    final rating = _extractRating();

    final cs = Theme.of(context).colorScheme;
    return _PressableCard(
      onTap: widget.onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.surface, cs.surfaceContainerHighest],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.07),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (only if non-placeholder)
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
                        errorWidget: (ctx, url, err) => const SizedBox.shrink(),
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
                                color: cs.onSurface,
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
                                    ? cs.error
                                    : cs.surfaceContainerHighest,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Price + type badge + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            priceText,
                            style: GoogleFonts.cinzel(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
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
                            backgroundColor: cs.surfaceContainerHighest,
                            backgroundImage: (authorPhotoUrl != null &&
                                    authorPhotoUrl.isNotEmpty)
                                ? CachedNetworkImageProvider(authorPhotoUrl)
                                : null,
                            child: (authorPhotoUrl == null ||
                                    authorPhotoUrl.isEmpty)
                                ? Text(
                                    avatarLetter,
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (rating > 0) ...[
                            Icon(Icons.star_rounded,
                                size: 14, color: cs.primary),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: cs.surfaceContainerHighest, size: 18),
                        ],
                      ),

                      // Reply / chat button — not my card
                      if (!_isMyCard)
                        Observer(
                          builder: (_) {
                            final store = sl<ServiceStore>();
                            final replied = store.hasReplied(widget.service.id);
                            final canReply = status == null || status == 'active';

                            // Nothing to show if not replied and can't reply
                            if (!replied && !canReply) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: replied
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openChat(context),
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          size: 16,
                                        ),
                                        label: const Text('Перейти в чат'),
                                      ),
                                    )
                                  : SizedBox(
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<void> _onReply(BuildContext context) async {
    final store = sl<ServiceStore>();
    final nav = Navigator.of(context);
    final snackbar = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    // Wait one frame so the dialog route is fully pushed before any pop.
    await WidgetsBinding.instance.endOfFrame;
    try {
      await store.createReply(widget.service.id);
      if (!context.mounted) return;
      await _openChat(context, nav: nav, snackbar: snackbar);
    } catch (_) {
      if (!mounted) return;
      _safePopDialog(nav);
      final forbidden = store.replyForbidden;
      snackbar.showSnackBar(SnackBar(
        content: Text(forbidden
            ? 'Вы не можете откликнуться на эту задачу'
            : 'Ошибка отклика'),
      ));
    }
  }

  Future<void> _openChat(
    BuildContext context, {
    NavigatorState? nav,
    ScaffoldMessengerState? snackbar,
  }) async {
    final messengerStore = sl<MessengerStore>();
    final author = widget.service.author;
    if (author == null || author.uid.isEmpty) return;

    final navigator = nav ?? Navigator.of(context);
    final messenger = snackbar ?? ScaffoldMessenger.of(context);

    final dialogAlreadyOpen = navigator.canPop();
    if (!dialogAlreadyOpen) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await WidgetsBinding.instance.endOfFrame;
    }

    try {
      await messengerStore.createChat(
        userId: author.uid,
        cardId: widget.service.id,
      );
      await messengerStore.loadChats();

      ChatEntity? chat;
      try {
        chat = messengerStore.customerChats
            .firstWhere((c) => c.card.id == widget.service.id);
      } catch (_) {
        try {
          chat = messengerStore.merchantChats
              .firstWhere((c) => c.card.id == widget.service.id);
        } catch (_) {}
      }

      if (chat == null || !mounted) return;
      messengerStore.selectChat(chat);
      _safePopDialog(navigator);
      if (context.mounted) context.push('/chat', extra: messengerStore);
    } catch (e) {
      if (!mounted) return;
      _safePopDialog(navigator);
      messenger.showSnackBar(SnackBar(content: Text('Ошибка чата: $e')));
    }
  }

  void _safePopDialog(NavigatorState nav) {
    try {
      if (nav.canPop()) nav.pop();
    } catch (_) {}
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableCard({required this.child, this.onTap});
  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 180),
    lowerBound: 0.97,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _ctrl.value, child: child),
        child: widget.child,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        type,
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _resolveColor(status, cs);
    final label = _resolveLabel(status);
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

  static Color _resolveColor(String status, ColorScheme cs) {
    if (status == 'active') return cs.primary;
    if (status == 'in-progress') return AppColors.warning;
    if (status == 'completed') return AppColors.success;
    if (status == 'closed') return cs.error;
    if (status == 'closed-with-bad-result') return cs.error;
    return cs.onSurfaceVariant;
  }

  static String _resolveLabel(String status) {
    if (status == 'active') return 'Активно';
    if (status == 'in-progress') return 'В работе';
    if (status == 'completed') return 'Завершено';
    if (status == 'closed') return 'Закрыто';
    if (status == 'closed-with-bad-result') return 'Закрыто';
    return status;
  }
}
