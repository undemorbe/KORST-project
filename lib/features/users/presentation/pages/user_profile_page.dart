import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool isOwnProfileHint;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.isOwnProfileHint = false,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserProfileRepository _repository = sl<UserProfileRepository>();
  final AuthStore _authStore = sl<AuthStore>();
  late Future<UserProfileEntity> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _repository.getUserProfile(widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureProfile = _repository.getUserProfile(widget.userId);
    });
    await _futureProfile;
  }

  Future<void> _showReviewDialog() async {
    final commentController = TextEditingController();
    double rating = 5;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Оставить отзыв'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final current = index + 1;
                      return IconButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                          setStateDialog(() {
                            rating = current.toDouble();
                          });
                        },
                        icon: Icon(
                          current <= rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Комментарий'),
                    maxLines: 3,
                    enabled: !isSubmitting,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Введите комментарий')),
                      );
                      return;
                    }
                    try {
                      setStateDialog(() {
                        isSubmitting = true;
                      });
                      await _repository.postReview(
                        userId: widget.userId,
                        rating: rating,
                        comment: text,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      await _reload();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Отзыв отправлен')),
                      );
                    } catch (e) {
                      setStateDialog(() {
                        isSubmitting = false;
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Отправить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль пользователя')),
      body: FutureBuilder<UserProfileEntity>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Профиль не найден'));
          }

          final isMe = _isMe(profile);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            (profile.name.trim().isNotEmpty ? profile.name.trim()[0] : '?').toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${profile.name} ${profile.surname ?? ''}'.trim(),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (isMe)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Это вы',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isMe) ...[
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/edit-profile'),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Редактировать профиль'),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ..._buildRatingStars(profile.rating),
                                  const SizedBox(width: 8),
                                  Text(profile.rating.toStringAsFixed(1)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if ((profile.description ?? '').trim().isNotEmpty)
                                Text(
                                  profile.description!.trim(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Контакты',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildContactTile(
                          icon: Icons.phone,
                          title: 'Телефон',
                          value: profile.phone,
                        ),
                        ..._buildContacts(profile.contacts),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Карточки пользователя',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('${profile.cards.length}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (profile.cards.isEmpty)
                          const Text('Пользователь ещё не создал карточек')
                        else
                          ListView.separated(
                            itemCount: profile.cards.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final card = profile.cards[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(card.title),
                                subtitle: Text('${card.price.toStringAsFixed(0)} ${card.currency}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/service-details', extra: card),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Отзывы о пользователе',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!isMe)
                              FilledButton.icon(
                                onPressed: _showReviewDialog,
                                icon: const Icon(Icons.add_comment),
                                label: const Text('Оставить отзыв'),
                              ),
                          ],
                        ),
                        if (isMe) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Вы видите отзывы других пользователей о вас',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (profile.reviews.isEmpty)
                          const Text('Пока нет отзывов')
                        else
                          ListView.separated(
                            itemCount: profile.reviews.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final review = profile.reviews[index];
                              final authorFullName =
                                  '${review.author.name} ${review.author.surname ?? ''}'.trim();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        authorFullName.isEmpty ? 'Пользователь' : authorFullName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(review.rating.toStringAsFixed(1)),
                                  ],
                                ),
                                subtitle: Text(review.comment),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Профиль обновлён: ${profile.updated.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isMe(UserProfileEntity profile) {
    if (widget.isOwnProfileHint) return true;
    final me = _authStore.userProfile;
    if (me == null) return false;
    if (widget.userId.isEmpty) return false;
    if (me.uid.isNotEmpty && me.uid == widget.userId) return true;
    if (me.phone.isNotEmpty && profile.phone.isNotEmpty && me.phone == profile.phone) return true;
    return false;
  }

  List<Widget> _buildRatingStars(double rating) {
    final widgets = <Widget>[];
    for (var i = 1; i <= 5; i++) {
      final diff = rating - i;
      final icon = diff >= 0
          ? Icons.star
          : diff > -1
              ? Icons.star_half
              : Icons.star_border;
      widgets.add(Icon(icon, color: Colors.amber, size: 20));
    }
    return widgets;
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value.trim().isEmpty ? '—' : value.trim()),
    );
  }

  List<Widget> _buildContacts(Map<String, dynamic> contacts) {
    final widgets = <Widget>[
      const Divider(height: 16),
    ];
    final email = contacts['email'];
    final telegram = contacts['telegram'];
    final others = contacts['others'];

    if (email is String && email.trim().isNotEmpty) {
      widgets.add(
        _buildContactTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: email,
        ),
      );
    }

    if (telegram is String && telegram.trim().isNotEmpty) {
      widgets.add(
        _buildContactTile(
          icon: Icons.send_outlined,
          title: 'Telegram',
          value: telegram,
        ),
      );
    }

    if (others is Map) {
      final map = Map<String, dynamic>.from(others);
      for (final entry in map.entries) {
        final value = entry.value?.toString() ?? '';
        if (value.trim().isEmpty) continue;
        widgets.add(
          _buildContactTile(
            icon: Icons.link,
            title: entry.key,
            value: value,
          ),
        );
      }
    }

    if (widgets.length == 1) {
      return [
        const Divider(height: 16),
        const Text('Контакты не заполнены'),
      ];
    }

    return widgets;
  }
}
