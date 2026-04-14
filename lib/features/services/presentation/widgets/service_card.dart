import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/service_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/glass.dart';
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
    final cardRadius = BorderRadius.circular(20);
    final borderColor = colors.outlineVariant.withValues(alpha: 0.4);
    final surfaceColor = colors.surface.withValues(alpha: 0.95);
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
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Glass(
          blurSigma: 24,
          opacity: 0.85,
          color: surfaceColor,
          borderColor: borderColor,
          borderWidth: 1,
          borderRadius: cardRadius,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.9,
                        ),
                        child: widget.service.imageUrl.isNotEmpty
                            ? Hero(
                                tag: heroTag,
                                child: CachedNetworkImage(
                                  imageUrl: widget.service.imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 800,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: muted.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: muted.withValues(alpha: 0.7),
                                ),
                              ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Glass(
                          blurSigma: 8,
                          opacity: 0.34,
                          color: Colors.black.withValues(alpha: 0.34),
                          borderColor: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              priceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Glass(
                          blurSigma: 12,
                          opacity: 0.6,
                          borderColor: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 42,
                            width: 42,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey(widget.isFavorite),
                                  color: widget.isFavorite
                                      ? Colors.red
                                      : Colors.black87,
                                  size: 24,
                                ),
                              ),
                              onPressed: widget.onFavoriteToggle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.service.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.service.description.trim(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: muted, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: colors.primaryContainer,
                              backgroundImage: (authorPhotoUrl != null && authorPhotoUrl.isNotEmpty)
                                  ? CachedNetworkImageProvider(authorPhotoUrl)
                                  : null,
                              child: (authorPhotoUrl == null || authorPhotoUrl.isEmpty)
                                  ? Text(
                                      avatarLetter,
                                      style: Theme.of(context).textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colors.onPrimaryContainer,
                                            fontSize: 13,
                                          ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                  ),
                                  if (authorRating > 0) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          final filled =
                                              index < authorRating.round();
                                          return Icon(
                                            filled
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 12,
                                            color: Colors.amber,
                                          );
                                        }),
                                        const SizedBox(width: 4),
                                        Text(
                                          authorRating.toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: muted,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Glass(
                                blurSigma: 10,
                                opacity: 0.5,
                                borderColor: borderColor,
                                borderWidth: 1,
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        authorRating.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.service.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: widget.service.tags
                              .take(3)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.secondaryContainer.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: colors.outline.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: colors.onSecondaryContainer,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
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
