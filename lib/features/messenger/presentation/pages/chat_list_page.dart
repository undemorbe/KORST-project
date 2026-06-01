import 'package:korst/core/theme/app_colors.dart';
import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/animated_gradient_background.dart';
import '../../domain/entities/chat_entity.dart';
import '../store/messenger_store.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
  final MessengerStore _store = sl<MessengerStore>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.loadChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(
        title: const SizedBox.shrink(),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.border),
          ),
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.muted,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: l10n.messagesAsBuyer),
            Tab(text: l10n.messagesAsSeller),
          ],
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(child: SizedBox.expand()),
          Observer(
            builder: (_) {
              if (_store.isLoading && _store.allChats.isEmpty) {
                return const ChatShimmer();
              }

              if (_store.errorMessage != null && _store.allChats.isEmpty) {
                return ErrorState(
                  message: _store.errorMessage!,
                  icon: Icons.cloud_off_outlined,
                  onRetry: _store.loadChats,
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        56,
                  ),
                  AppPageHeader(
                    title: l10n.messagesTitle,
                    subtitle: l10n.messagesStart,
                    icon: Icons.forum_outlined,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChatList(_store.merchantChats, 'customer'),
                        _buildChatList(_store.customerChats, 'merchant'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
     
    );
  }

  Widget _buildChatList(List<ChatEntity> chats, String type) {
    final l10n = AppLocalizations.of(context)!;
    if (chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _store.loadChats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                        boxShadow: const [
                          BoxShadow(color: AppColors.goldGlow, blurRadius: 12),
                        ],
                      ),
                      child: Icon(
                        type == 'customer'
                            ? Icons.work_outline
                            : Icons.person_outline,
                        size: 48,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      type == 'customer'
                          ? l10n.messagesNoChatsBuyer
                          : l10n.messagesNoChatsSeller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _store.loadChats,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 0,
          bottom: MediaQuery.of(context).padding.bottom + 100,
        ),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _ChatListTile(
            chat: chat,
            store: _store,
            onTap: () => _openChat(chat),
          );
        },
      ),
    );
  }

  void _openChat(ChatEntity chat) {
    _store.selectChat(chat);
    context.push('/chat', extra: _store);
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatEntity chat;
  final MessengerStore store;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.chat,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lastMessage = chat.lastMessage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline),
          boxShadow: [
            BoxShadow(color: cs.primary.withValues(alpha: 0.07), blurRadius: 8),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outline, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.outlineVariant,
                    backgroundImage: chat.user.imageUrl != null
                        ? NetworkImage(chat.user.imageUrl!)
                        : null,
                    child: chat.user.imageUrl == null
                        ? Text(
                            chat.user.name[0].toUpperCase(),
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${chat.user.name} ${chat.user.surname ?? ''}'
                                  .trim(),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastMessage != null)
                            Text(
                              _formatTime(lastMessage.created),
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.card.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          lastMessage.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final count = store.unreadCounts[chat.id] ?? 0;
                    final showBadge =
                        count > 0 || (chat.lastMessage?.isSeen == false);
                    if (!showBadge) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: count > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}.${time.month}';
  }
}
