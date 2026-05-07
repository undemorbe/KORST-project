import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/service_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';

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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final author = widget.service.author;
    final me = sl<AuthStore>().userProfile;
    final isMyCard =
        author != null &&
        author.uid.isNotEmpty &&
        (me?.uid.isNotEmpty ?? false) &&
        author.uid == me!.uid;
    final authorName = author == null
        ? 'User'
        : isMyCard
        ? l10n.serviceYou
        : '${author.name} ${author.surname ?? ''}'.trim().isEmpty
        ? 'User'
        : '${author.name} ${author.surname ?? ''}'.trim();
    final authorRating = _extractAuthorRating();
    final colors = Theme.of(context).colorScheme;
    final cardRadius = BorderRadius.circular(8);
    final borderColor = colors.outlineVariant.withValues(alpha: 0.7);
    final surfaceColor = colors.surface.withValues(alpha: 0.98);
    final muted = colors.onSurfaceVariant;
    final priceText =
        '${widget.service.price.toStringAsFixed(0)} ${widget.service.currency}';
    final heroTag = widget.heroTag ?? 'service-image-${widget.service.id}';
    final authorPhotoUrl = author?.photoUrl;
    final avatarLetter =
        (authorName.trim().isNotEmpty ? authorName.trim()[0] : '?')
            .toUpperCase();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Material(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: cardRadius,
            side: BorderSide(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 172),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 126,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.service.imageUrl.isNotEmpty
                            ? Hero(
                                tag: heroTag,
                                child: CachedNetworkImage(
                                  imageUrl: widget.service.imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 520,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.broken_image_outlined,
                                    color: muted,
                                  ),
                                ),
                              )
                            : ColoredBox(
                                color: colors.surfaceContainerHighest,
                                child: Icon(Icons.image_outlined, color: muted),
                              ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.62),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          right: 10,
                          child: Text(
                            priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.service.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        height: 1.12,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: IconButton(
                                  tooltip: l10n.favoritesTitle,
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    widget.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: widget.isFavorite
                                        ? colors.secondary
                                        : muted,
                                  ),
                                  onPressed: widget.onFavoriteToggle,
                                ),
                              ),
                            ],
                          ),
                          if (widget.service.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              widget.service.description.trim(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: muted, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          if (widget.service.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: widget.service.tags.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: muted),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: colors.primaryContainer,
                                backgroundImage:
                                    (authorPhotoUrl != null &&
                                        authorPhotoUrl.isNotEmpty)
                                    ? CachedNetworkImageProvider(authorPhotoUrl)
                                    : null,
                                child:
                                    (authorPhotoUrl == null ||
                                        authorPhotoUrl.isEmpty)
                                    ? Text(
                                        avatarLetter,
                                        style: TextStyle(
                                          color: colors.onPrimaryContainer,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
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
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (authorRating > 0) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                Text(
                                  authorRating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                              Icon(Icons.chevron_right, color: muted, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _extractAuthorRating() {
    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final author = widget.service.author;
    if (author == null) return widget.service.rating;
    final values = [
      author.contacts['rating'],
      author.contacts['rate'],
      author.contacts['avg_rating'],
      author.contacts['average_rating'],
      widget.service.rating,
    ];
    for (final value in values) {
      final parsed = toDouble(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }
}
