import 'package:flutter/material.dart';
import '../../domain/entities/service_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    final author = service.author;
    final me = sl<AuthStore>().userProfile;
    final isMyCard = author != null &&
        author.uid.isNotEmpty &&
        (me?.uid.isNotEmpty ?? false) &&
        author.uid == me!.uid;
    final authorName = author == null
        ? 'Пользователь'
        : isMyCard
            ? 'Вы'
            : '${author.name} ${author.surname ?? ''}'.trim().isEmpty
            ? 'Пользователь'
            : '${author.name} ${author.surname ?? ''}'.trim();
    final authorRating = _extractAuthorRating();
    final colors = Theme.of(context).colorScheme;
    final cardRadius = BorderRadius.circular(18);
    final borderColor = colors.outlineVariant.withValues(alpha: 0.45);
    final surfaceColor = colors.surface.withValues(alpha: 0.9);
    final muted = colors.onSurfaceVariant;
    final priceText = '${service.price.toStringAsFixed(0)} ${service.currency}';
    final avatarLetter = (authorName.trim().isNotEmpty ? authorName.trim()[0] : '?').toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: borderColor),
      ),
      color: surfaceColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Container(
                    height: 170,
                    width: double.infinity,
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.85),
                    child: service.imageUrl.isNotEmpty
                        ? Image.network(
                            service.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 46,
                                  color: muted.withValues(alpha: 0.7),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 46,
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
                            Colors.black.withValues(alpha: 0.35),
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
                      borderColor: Colors.white.withValues(alpha: 0.16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          priceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
                      opacity: 0.55,
                      borderColor: Colors.white.withValues(alpha: 0.22),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black87,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primaryContainer,
                          child: Text(
                            avatarLetter,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Glass(
                            blurSigma: 10,
                            opacity: 0.5,
                            borderColor: borderColor,
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    authorRating.toStringAsFixed(1),
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
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
                  if (service.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: service.tags
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: colors.onSecondaryContainer,
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
    );
  }

  double _extractAuthorRating() {
    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final author = service.author;
    if (author == null) return service.rating;
    final values = [
      author.contacts['rating'],
      author.contacts['rate'],
      author.contacts['avg_rating'],
      author.contacts['average_rating'],
      service.rating,
    ];
    for (final value in values) {
      final parsed = toDouble(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }
}
