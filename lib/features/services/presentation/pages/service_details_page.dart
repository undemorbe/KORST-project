import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/executor_entity.dart';
import '../store/service_store.dart';
import '../../../favorites/presentation/store/favorites_store.dart';

import '../../../auth/presentation/store/auth_store.dart';
import '../../../messenger/presentation/store/messenger_store.dart';

class ServiceDetailsPage extends StatefulWidget {
  final ServiceEntity service;
  final String? heroTag;

  const ServiceDetailsPage({super.key, required this.service, this.heroTag});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final ServiceStore _serviceStore = sl<ServiceStore>();

  bool _canEdit(ServiceEntity service) {
    final user = sl<AuthStore>().userProfile;
    final author = service.author;
    if (user == null || author == null) return false;
    if (author.uid.isNotEmpty && user.uid.isNotEmpty) {
      if (author.uid == user.uid) return true;
    }

    final cleanAuthorPhone = author.phone.replaceAll(RegExp(r'\D'), '');
    final cleanUserPhone = user.phone.replaceAll(RegExp(r'\D'), '');
    final cleanUserIdPhone = user.uid.replaceAll(RegExp(r'\D'), '');

    if (cleanAuthorPhone.isNotEmpty) {
      if (cleanUserPhone.isNotEmpty && cleanAuthorPhone == cleanUserPhone) {
        return true;
      }
      if (cleanUserIdPhone.isNotEmpty && cleanAuthorPhone == cleanUserIdPhone) {
        return true;
      }

      if (cleanAuthorPhone.length >= 10 && cleanUserPhone.length >= 10) {
        if (cleanAuthorPhone.substring(cleanAuthorPhone.length - 10) ==
            cleanUserPhone.substring(cleanUserPhone.length - 10)) {
          return true;
        }
      }
      if (cleanAuthorPhone.length >= 10 && cleanUserIdPhone.length >= 10) {
        if (cleanAuthorPhone.substring(cleanAuthorPhone.length - 10) ==
            cleanUserIdPhone.substring(cleanUserIdPhone.length - 10)) {
          return true;
        }
      }
    }

    return author.name.trim().toLowerCase() == user.name.trim().toLowerCase();
  }

  void _startChat(ServiceEntity service) async {
    final messengerStore = sl<MessengerStore>();
    final author = service.author;
    if (author == null || author.uid.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _serviceStore.createReply(service.id);

      // Create the chat
      await messengerStore.createChat(userId: author.uid, cardId: service.id);

      // Reload chats to get the newly created chat
      await messengerStore.loadChats();

      // Find and select the chat for this service
      final chat = messengerStore.merchantChats.firstWhere(
        (c) => c.card.id == service.id,
        orElse: () => messengerStore.customerChats.firstWhere(
          (c) => c.card.id == service.id,
          orElse: () => throw Exception('Chat not found after creation'),
        ),
      );
      messengerStore.selectChat(chat);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      // Navigate to chat
      context.push('/chat', extra: messengerStore);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.failedToCreateChatPrefix}$e",
          ),
        ),
      );
    }
  }

  Future<void> _shareService(ServiceEntity service) async {
    final link = 'korst:///service/${service.id}';
    final title = service.title.trim().isEmpty
        ? AppLocalizations.of(context)!.serviceCard
        : service.title.trim();
    final price = '${service.price.toStringAsFixed(0)} ${service.currency}';
    await SharePlus.instance.share(
      ShareParams(
        text:
            "$title\n$price${AppLocalizations.of(context)!.openInKorstPrefix}$link",
        subject: title,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _serviceStore.loadServiceDetails(widget.service.id);
    if (_canEdit(widget.service)) {
      _serviceStore.loadExecutors(widget.service.id);
    }
  }

  void _showCloseCardDialog(BuildContext context, ServiceEntity service) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Управление заказом',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Выберите действие для заказа',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _closeOption(
                context: context,
                service: service,
                label: 'Завершить успешно',
                sublabel: 'Работа выполнена',
                status: 'completed',
                color: const Color(0xFF6AAA6A),
              ),
              const SizedBox(height: 10),
              _closeOption(
                context: context,
                service: service,
                label: 'Закрыть без результата',
                sublabel: 'Исполнитель не засчитывается',
                status: 'closed-with-bad-result',
                color: const Color(0xFFAA4444),
              ),
              const SizedBox(height: 10),
              _closeOption(
                context: context,
                service: service,
                label: 'Переоткрыть (плохой результат)',
                sublabel: 'Исполнитель не засчитывается',
                status: 'reopen-with-bad-result',
                color: const Color(0xFFCCAA44),
              ),
              const SizedBox(height: 10),
              _closeOption(
                context: context,
                service: service,
                label: 'Переоткрыть (хороший результат)',
                sublabel: 'Исполнитель засчитывается',
                status: 'reopen-with-good-result',
                color: const Color(0xFF6AAA6A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _closeOption({
    required BuildContext context,
    required ServiceEntity service,
    required String label,
    required String sublabel,
    required String status,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        Navigator.of(context).pop();
        final messenger = ScaffoldMessenger.of(context);
        try {
          await _serviceStore.closeCard(cardId: service.id, status: status);
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Статус обновлён')),
            );
          }
        } catch (e) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Ошибка: $e')),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            Text(sublabel,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesStore = sl<FavoritesStore>();
    final serviceStore = _serviceStore;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Observer(
        builder: (_) {
          final currentService = serviceStore.services.firstWhere(
            (s) => s.id == widget.service.id,
            orElse: () => widget.service,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  if (_canEdit(currentService))
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          context.push('/edit-service', extra: currentService),
                    ),
                  if (_canEdit(currentService))
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showCloseCardDialog(context, currentService),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Закрыть заказ'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareService(currentService),
                  ),
                  Observer(
                    builder: (_) {
                      final isFavorite = favoritesStore.isFavorite(
                        currentService.id,
                      );
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () =>
                            favoritesStore.toggleFavorite(currentService.id),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    currentService.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      currentService.imageUrl.isNotEmpty
                          ? Hero(
                              tag:
                                  widget.heroTag ??
                                  'service-image-${currentService.id}',
                              child: CachedNetworkImage(
                                imageUrl: currentService.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.78),
                              Colors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.serviceDetailsTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentService.price.toStringAsFixed(0)} ${currentService.currency}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (currentService.author != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: currentService.author!.uid.isEmpty
                                ? null
                                : () => context.push(
                                    '/user-profile/${currentService.author!.uid}',
                                  ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${AppLocalizations.of(context)!.authorPrefix}${_canEdit(currentService) ? AppLocalizations.of(context)!.you : currentService.author!.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(5, (index) {
                                    final raw = currentService
                                        .author
                                        ?.contacts['rating'];
                                    final r = raw is num
                                        ? raw.toDouble()
                                        : currentService.rating;
                                    final filled = index < r.round();
                                    return Icon(
                                      filled ? Icons.star : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Builder(
                                    builder: (context) {
                                      final raw = currentService
                                          .author
                                          ?.contacts['rating'];
                                      final r = raw is num
                                          ? raw.toDouble()
                                          : currentService.rating;
                                      return Text(
                                        r.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  if (currentService.author!.uid.isNotEmpty)
                                    const Icon(
                                      Icons.open_in_new,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentService.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        currentService.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      if (!_canEdit(currentService) &&
                          currentService.author != null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _startChat(currentService),
                            icon: const Icon(Icons.handshake),
                            label: Text(
                              AppLocalizations.of(context)!.respondToTask,
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (_canEdit(currentService)) ...[
                        const SizedBox(height: 24),
                        _ExecutorsSection(
                          store: _serviceStore,
                          cardId: currentService.id,
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExecutorsSection extends StatelessWidget {
  final ServiceStore store;
  final String cardId;

  const _ExecutorsSection({required this.store, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (store.isLoadingExecutors) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (store.executorsError != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              store.executorsError!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          );
        }

        if (store.executors.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Откликов пока нет',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Отклики',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.04,
              ),
            ),
            const SizedBox(height: 12),
            ...store.executors.map(
              (e) => _ExecutorTile(
                executor: e,
                cardId: cardId,
                store: store,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExecutorTile extends StatelessWidget {
  final ExecutorEntity executor;
  final String cardId;
  final ServiceStore store;

  const _ExecutorTile({
    required this.executor,
    required this.cardId,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.borderSubtle,
                backgroundImage: executor.imageUrl != null &&
                        executor.imageUrl!.isNotEmpty
                    ? NetworkImage(executor.imageUrl!)
                    : null,
                child: executor.imageUrl == null || executor.imageUrl!.isEmpty
                    ? Text(
                        executor.name.isNotEmpty
                            ? executor.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w700,
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
                      executor.displayName,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.ratingStar,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          executor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Одобрить',
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 26,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await store.approveExecutor(
                          cardId: cardId,
                          executorId: executor.id,
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Исполнитель одобрен'),
                          ),
                        );
                      } catch (_) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(store.errorMessage ?? 'Ошибка'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'Отклонить',
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                      size: 26,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await store.rejectExecutor(
                          cardId: cardId,
                          executorId: executor.id,
                        );
                        await store.loadExecutors(cardId);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Исполнитель отклонён'),
                          ),
                        );
                      } catch (_) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(store.errorMessage ?? 'Ошибка'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
