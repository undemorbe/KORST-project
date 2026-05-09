import 'package:korst/core/theme/app_colors.dart';
import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/shimmer.dart';
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.errorLoading}: ${_store.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _store.loadChats,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
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
      floatingActionButton: Observer(
        builder: (_) => _store.isLoading
            ? const SizedBox.shrink()
            : FloatingActionButton(
                heroTag: 'chat_list_fab',
                onPressed: _store.loadChats,
                child: const Icon(Icons.refresh),
              ),
      ),
    );
  }

  Widget _buildChatList(List<ChatEntity> chats, String type) {
    final l10n = AppLocalizations.of(context)!;
    if (chats.isEmpty) {
      return Center(
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
                type == 'customer' ? Icons.work_outline : Icons.person_outline,
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
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 0,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _ChatListTile(chat: chat, onTap: () => _openChat(chat));
      },
    );
  }

  void _openChat(ChatEntity chat) {
    _store.selectChat(chat);
    context.push('/chat', extra: _store);
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatEntity chat;
  final VoidCallback onTap;

  const _ChatListTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final hasUnread = lastMessage?.isSeen == false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.goldGlow, blurRadius: 8),
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
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.borderSubtle,
                    backgroundImage: chat.user.imageUrl != null
                        ? NetworkImage(chat.user.imageUrl!)
                        : null,
                    child: chat.user.imageUrl == null
                        ? Text(
                            chat.user.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryLight,
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
                              style: const TextStyle(
                                color: AppColors.onBackground,
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
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.card.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          lastMessage.text,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
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
