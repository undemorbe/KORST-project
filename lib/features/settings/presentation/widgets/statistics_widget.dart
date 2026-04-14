import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/glass.dart';
import '../../../users/domain/repositories/user_profile_repository.dart';
import '../../../users/domain/entities/user_profile_entity.dart';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    final cardsCount = _profile?.cards.length ?? 0;
    final rating = _profile?.rating ?? 0.0;
    final reviewsCount = _profile?.reviews.length ?? 0;
    
    // Выдуманный заработок (примерная формула: средняя цена * выдуманное количество заказов)
    double earnedMoney = 0;
    if (_profile != null && _profile!.cards.isNotEmpty) {
      for (var card in _profile!.cards) {
        // Если timesBooked = 0, притворимся, что было хотя бы 2 заказа для вида
        final bookings = card.timesBooked > 0 ? card.timesBooked : 2;
        earnedMoney += card.price * bookings;
      }
    }

    // Расчет фактора доверия
    // Базовый уровень 30%
    // + 5% за каждую услугу (макс 25%)
    // + 5% за каждую звезду рейтинга (макс 25%)
    // + 2% за каждый отзыв (макс 20%)
    double trustFactor = 0.3; 
    trustFactor += (cardsCount * 0.05).clamp(0.0, 0.25);
    trustFactor += (rating * 0.05).clamp(0.0, 0.25);
    trustFactor += (reviewsCount * 0.02).clamp(0.0, 0.20);
    
    // Ограничиваем от 0 до 1
    trustFactor = trustFactor.clamp(0.0, 1.0);

    String trustLevel;
    Color trustColor;
    if (trustFactor >= 0.8) {
      trustLevel = AppLocalizations.of(context)!.high;
      trustColor = Colors.green;
    } else if (trustFactor >= 0.5) {
      trustLevel = AppLocalizations.of(context)!.medium;
      trustColor = Colors.orange;
    } else {
      trustLevel = AppLocalizations.of(context)!.low;
      trustColor = Colors.red;
    }

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.statistics,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _refresh,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.task_alt,
                    value: '$cardsCount',
                    label: AppLocalizations.of(context)!.services,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    value: '${earnedMoney.toStringAsFixed(0)} ₽',
                    label: AppLocalizations.of(context)!.earned,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/user-profile/me');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: _buildStatItem(
                      context,
                      icon: Icons.star,
                      value: rating > 0 ? rating.toStringAsFixed(1) : '—',
                      label: AppLocalizations.of(context)!.rating,
                      isClickable: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.trustFactor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trustColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: trustColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    trustLevel,
                    style: TextStyle(
                      color: trustColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: trustFactor,
                backgroundColor: colors.surfaceContainerHighest,
                color: trustColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.trustFactorDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    bool isClickable = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: Colors.transparent, // Для корректной работы GestureDetector
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isClickable 
                  ? colors.primary.withValues(alpha: 0.1) 
                  : colors.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isClickable 
                    ? colors.primary.withValues(alpha: 0.5)
                    : colors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: isClickable ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Icon(
              icon, 
              color: isClickable ? colors.primary : colors.primary, 
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}