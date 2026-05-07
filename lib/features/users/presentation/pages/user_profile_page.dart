import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    _futureProfile = _loadProfile();
  }

  Future<UserProfileEntity> _loadProfile() {
    if (widget.isOwnProfileHint) {
      return _repository.getOwnProfile();
    }
    return _repository.getUserProfile(widget.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureProfile = _loadProfile();
    });
    await _futureProfile;
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 60,
    );
    if (file == null) return;

    if (!mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _repository.uploadProfileImage(file.path);
      // Wait, we need to also update the user entity in AuthStore?
      // Since we just uploaded it, the backend should associate it with the user if we call /user/save-image
      // We will reload the profile.
      if (mounted) {
        Navigator.pop(context); // close dialog
        _reload();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.errorLoadingPhotoPrefix}$e",
            ),
          ),
        );
      }
    }
  }

  Future<void> _showReviewDialog() async {
    final commentController = TextEditingController();
    double rating = 5;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.profileReviews),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final currentFull = index + 1;
                      return GestureDetector(
                        onTapDown: (details) {
                          if (isSubmitting) return;
                          setStateDialog(() {
                            if (details.localPosition.dx < 20) {
                              // size is 32 + 8 padding total roughly 40, half is 20
                              rating = currentFull - 0.5;
                            } else {
                              rating = currentFull.toDouble();
                            }
                          });
                        },
                        onPanUpdate: (details) {
                          if (isSubmitting) return;
                          setStateDialog(() {
                            if (details.localPosition.dx < 20) {
                              rating = currentFull - 0.5;
                            } else {
                              rating = currentFull.toDouble();
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Icon(
                            rating >= currentFull
                                ? Icons.star
                                : rating >= currentFull - 0.5
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.profileDescription,
                    ),
                    maxLines: 3,
                    enabled: !isSubmitting,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.errorValidation,
                          ),
                        ),
                      );
                      return;
                    }
                    try {
                      if (!builderContext.mounted) return;
                      setStateDialog(() {
                        isSubmitting = true;
                      });
                      await _repository.postReview(
                        userId: widget.userId,
                        rating: rating,
                        comment: text,
                      );
                      if (!builderContext.mounted) return;
                      Navigator.of(builderContext).pop();
                      await _reload();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.done),
                        ),
                      );
                    } catch (e) {
                      if (!builderContext.mounted) return;
                      setStateDialog(() {
                        isSubmitting = false;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.messagesSend),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(title: const SizedBox.shrink()),
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
                    OutlinedButton(onPressed: _reload, child: Text(l10n.retry)),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return Center(child: Text(l10n.errorNotFound));
          }

          final isMe = _isMe(profile);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              children: [
                AppPageHeader(
                  title: l10n.profileTitle,
                  subtitle: isMe ? l10n.myProfile : l10n.publicProfile,
                  icon: Icons.person_outline,
                  trailing: isMe
                      ? IconButton.filled(
                          onPressed: () async {
                            await context.push('/edit-profile');
                            if (!mounted) return;
                            _reload();
                          },
                          icon: const Icon(Icons.edit),
                        )
                      : null,
                ),
                GlassCard(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: isMe ? _uploadPhoto : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                backgroundImage:
                                    profile.photoUrl != null &&
                                        profile.photoUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        profile.photoUrl!,
                                      )
                                    : null,
                                child:
                                    profile.photoUrl == null ||
                                        profile.photoUrl!.isEmpty
                                    ? Text(
                                        (profile.name.trim().isNotEmpty
                                                ? profile.name.trim()[0]
                                                : '?')
                                            .toUpperCase(),
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    : null,
                              ),
                              if (isMe)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${profile.name} ${profile.surname ?? ''}'
                                          .trim(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (isMe)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        l10n.serviceYou,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
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
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildContactTile(
                          icon: Icons.phone,
                          title: l10n.profilePhone,
                          value: profile.phone,
                        ),
                        ..._buildContacts(profile.contacts),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.profileServices,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('${profile.cards.length}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (profile.cards.isEmpty)
                          Text(l10n.profileNoServices)
                        else
                          ListView.separated(
                            itemCount: profile.cards.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final card = profile.cards[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(card.title),
                                subtitle: Text(
                                  '${card.price.toStringAsFixed(0)} ${card.currency}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push(
                                  '/service-details',
                                  extra: card,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.profileReviews,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!isMe)
                              FilledButton.icon(
                                onPressed: _showReviewDialog,
                                icon: const Icon(Icons.add_comment),
                                label: Text(l10n.profileReviews),
                              ),
                          ],
                        ),
                        if (isMe) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reviews from other users about you',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (profile.reviews.isEmpty)
                          Text(
                            l10n.noFavorites.replaceFirst(
                              'favorites',
                              'reviews',
                            ),
                          )
                        else
                          ListView.separated(
                            itemCount: profile.reviews.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final review = profile.reviews[index];
                              final authorFullName =
                                  '${review.author.name} ${review.author.surname ?? ''}'
                                      .trim();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        authorFullName.isEmpty
                                            ? 'User'
                                            : authorFullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ...List.generate(5, (starIndex) {
                                      IconData iconData;
                                      final double diff =
                                          review.rating - starIndex;
                                      if (diff >= 0.75) {
                                        iconData = Icons.star;
                                      } else if (diff >= 0.25) {
                                        iconData = Icons.star_half;
                                      } else {
                                        iconData = Icons.star_border;
                                      }
                                      return Icon(
                                        iconData,
                                        size: 16,
                                        color: Colors.amber,
                                      );
                                    }),
                                    const SizedBox(width: 4),
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
                  '${l10n.updated}: ${profile.updated.toLocal()}',
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
    if (me.phone.isNotEmpty &&
        profile.phone.isNotEmpty &&
        me.phone == profile.phone) {
      return true;
    }
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
    final widgets = <Widget>[const Divider(height: 16)];
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
          _buildContactTile(icon: Icons.link, title: entry.key, value: value),
        );
      }
    }

    if (widgets.length == 1) {
      return [const Divider(height: 16), const Text('No contacts provided')];
    }

    return widgets;
  }
}
