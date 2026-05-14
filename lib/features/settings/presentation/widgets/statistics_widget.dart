import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass.dart';
import '../../../users/domain/repositories/user_profile_repository.dart';
import '../../../users/domain/entities/user_profile_entity.dart';
import '../../../users/domain/entities/user_review_entity.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class StatisticsWidget extends StatefulWidget {
  const StatisticsWidget({super.key});

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> {
  final UserProfileRepository _repository = sl<UserProfileRepository>();
  UserProfileEntity? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final profile = await _repository.getOwnProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Real data from /user/me + /user/reviews
    final cards = _profile?.cards ?? [];
    final cardsTotal = cards.length;
    final cardsActive = cards.where((c) => c.status == 'active').length;
    final cardsInProgress = cards.where((c) => c.status == 'in-progress').length;
    final cardsCompleted = cards.where((c) => c.status == 'completed').length;
    final cardsClosed = cards.where((c) => c.status == 'closed').length;

    final rating = _profile?.rating ?? 0.0;
    final reviews = _profile?.reviews ?? [];
    final reviewsCount = reviews.length;
    final repliesInfo = _profile?.repliesInfo;

    // Average review rating (from /user/reviews)
    final avgReviewRating = reviewsCount > 0
        ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewsCount
        : 0.0;

    // Success rate: completed / (completed + closed) — only if any closed cards exist
    final closedTotal = cardsCompleted + cardsClosed;
    final successRate = closedTotal > 0 ? cardsCompleted / closedTotal : null;

    // Trust factor — based on real data
    double trustFactor = 0.3;
    trustFactor += (cardsTotal * 0.05).clamp(0.0, 0.25);
    trustFactor += (rating * 0.05).clamp(0.0, 0.25);
    trustFactor += (reviewsCount * 0.02).clamp(0.0, 0.20);
    trustFactor = trustFactor.clamp(0.0, 1.0);

    String trustLevel;
    Color trustColor;
    if (trustFactor >= 0.8) {
      trustLevel = l10n.high;
      trustColor = AppColors.success;
    } else if (trustFactor >= 0.5) {
      trustLevel = l10n.medium;
      trustColor = AppColors.warning;
    } else {
      trustLevel = l10n.low;
      trustColor = cs.error;
    }

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.statistics,
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: 0.08,
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20, color: cs.onSurfaceVariant),
                    onPressed: _refresh,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Rating + Reviews hero row ──
            Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    icon: Icons.star_rounded,
                    iconColor: cs.primary,
                    value: rating > 0 ? rating.toStringAsFixed(1) : '—',
                    label: l10n.rating,
                    onTap: () => context.push('/user-profile/me'),
                    highlight: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: cs.primary,
                    value: reviewsCount > 0
                        ? '$reviewsCount (${avgReviewRating.toStringAsFixed(1)}★)'
                        : '—',
                    label: l10n.profileReviews,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Cards grid ──
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    icon: Icons.layers_outlined,
                    value: '$cardsTotal',
                    label: l10n.services,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.search_rounded,
                    value: '$cardsActive',
                    label: 'Активные',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.hourglass_top_rounded,
                    value: '$cardsInProgress',
                    label: 'В работе',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$cardsCompleted',
                    label: 'Завершены',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            // ── Replies stats ──
            if (repliesInfo != null && repliesInfo.total > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.send_rounded,
                      value: '${repliesInfo.total}',
                      label: 'Откликов',
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.handshake_outlined,
                      value: '${repliesInfo.accepted}',
                      label: 'Принято',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.verified_rounded,
                      value: '${repliesInfo.completed}',
                      label: 'Выполнено',
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.cancel_outlined,
                      value: '${repliesInfo.failed}',
                      label: 'Провалено',
                      color: cs.error,
                    ),
                  ),
                ],
              ),
            ],

            // ── Success rate bar (only when meaningful) ──
            if (successRate != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Успешность',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(successRate * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(width: double.infinity, color: cs.outlineVariant),
                      FractionallySizedBox(
                        widthFactor: successRate,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.surfaceContainerHighest, cs.primary],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Trust factor ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.trustFactor,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trustColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: trustColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    trustLevel,
                    style: TextStyle(
                      color: trustColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(width: double.infinity, color: cs.outlineVariant),
                    FractionallySizedBox(
                      widthFactor: trustFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.surfaceContainerHighest, trustColor],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.trustFactorDesc,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            ),

            // ── Recent reviews ──
            if (reviews.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.profileReviews,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 10),
              ...reviews.take(2).map((r) => _ReviewRow(review: r)),
              if (reviews.length > 2)
                GestureDetector(
                  onTap: () => context.push('/my-reviews'),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Builder(
                      builder: (context) {
                        final cs = Theme.of(context).colorScheme;
                        return Text(
                          'Все отзывы (${reviews.length})',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: cs.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Hero stat (big, clickable) ──────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  const _HeroStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlight ? cs.primary : cs.outline,
          ),
          boxShadow: highlight
              ? [BoxShadow(color: cs.primary.withValues(alpha: 0.07), blurRadius: 8)]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Small chip stat ──────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Review row ────────────────────────────────────────────────────────────────
class _ReviewRow extends StatelessWidget {
  final UserReviewEntity review;

  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rating = review.rating;
    final comment = review.comment;
    final authorName = review.author.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 13,
                    color: cs.primary,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  authorName,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(color: cs.onSurface, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
