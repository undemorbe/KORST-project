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
    return author != null &&
        author.uid.isNotEmpty &&
        author.uid == (me?.uid ?? '');
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

                      // Price + type badge + status badge
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
                              authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (rating > 0) ...[
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.ratingStar),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
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
    final messenger = ScaffoldMessenger.of(context);
    await store.createReply(widget.service.id);
    if (!mounted) return;
    final err = store.replyError;
    messenger.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(status);
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

  static Color _resolveColor(String status) {
    if (status == 'active') return AppColors.primary;
    if (status == 'in-progress') return AppColors.warning;
    if (status == 'completed') return AppColors.success;
    if (status == 'closed') return AppColors.error;
    if (status == 'closed-with-bad-result') return AppColors.error;
    return AppColors.muted;
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
