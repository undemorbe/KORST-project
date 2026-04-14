import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/service_entity.dart';
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
      if (cleanUserPhone.isNotEmpty && cleanAuthorPhone == cleanUserPhone) return true;
      if (cleanUserIdPhone.isNotEmpty && cleanAuthorPhone == cleanUserIdPhone) return true;
      
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${AppLocalizations.of(context)!.failedToCreateChatPrefix}$e")));
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
        text: "$title\n$price${AppLocalizations.of(context)!.openInKorstPrefix}$link",
        subject: title,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _serviceStore.loadServiceDetails(widget.service.id);
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
                  background: currentService.imageUrl.isNotEmpty
                      ? Hero(
                          tag: widget.heroTag ?? 'service-image-${currentService.id}',
                          child: CachedNetworkImage(
                            imageUrl: currentService.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
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
                              borderRadius: BorderRadius.circular(20),
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

                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            currentService.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: currentService.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey.shade200,
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
                          child: OutlinedButton.icon(
                            onPressed: () => _startChat(currentService),
                            icon: const Icon(Icons.handshake),
                            label: Text(AppLocalizations.of(context)!.respondToTask),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
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
