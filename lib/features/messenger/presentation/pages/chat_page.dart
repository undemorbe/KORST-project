import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/di/injection_container.dart';
import 'package:korst/core/theme/animated_gradient_background.dart';
import 'package:korst/core/widgets/glass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/message_entity.dart';
import '../store/messenger_store.dart';

class ChatPage extends StatefulWidget {
  final MessengerStore store;

  const ChatPage({super.key, required this.store});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _showAllMessages = false;

  MessengerStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _store.selectChat(null);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chat = _store.selectedChat;
    if (chat == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Center(child: Text(l10n.errorNotFound)),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${chat.user.name} ${chat.user.surname ?? ''}'.trim()),
            InkWell(
              onTap: () => _navigateToService(chat.card.id),
              child: Text(
                chat.card.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(child: SizedBox.expand()),
          Column(
            children: [
              Expanded(
                child: Observer(
                  builder: (_) {
                    if (_store.isLoading && _store.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_store.errorMessage != null) {
                      return ErrorState(
                        message: _store.errorMessage!,
                        icon: Icons.cloud_off_outlined,
                        onRetry: () => _store.loadMessages(chat.id),
                      );
                    }

                    if (_store.messages.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.messagesEmpty,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final now = DateTime.now();
                    final weekAgo = now.subtract(const Duration(days: 7));
                    final allMsgs = _store.messages;
                    final hasOlder = allMsgs.any((m) => m.created.isBefore(weekAgo));
                    final filtered = _showAllMessages
                        ? allMsgs.toList()
                        : allMsgs.where((m) => !m.created.isBefore(weekAgo)).toList();
                    final displayItems = _buildDisplayItems(filtered);
                    final hasLoadMore = hasOlder && !_showAllMessages;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                        top:
                            MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            16,
                        bottom: 120,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: displayItems.length + (hasLoadMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // reverse: true → index 0 = bottom (newest), last index = top (oldest)
                        if (hasLoadMore && index == displayItems.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => _showAllMessages = true),
                                icon: const Icon(Icons.history, size: 16),
                                label: const Text('Показать старые сообщения'),
                              ),
                            ),
                          );
                        }
                        final item = displayItems[index];
                        if (item is DateTime) {
                          return _DateSeparatorWidget(
                            label: _formatDateLabel(item),
                          );
                        }
                        final message = item as MessageEntity;
                        // authorId != chat.user.id means message is mine
                        final isMe = message.authorId != chat.user.id;
                        return _MessageBubble(
                          message: message,
                          isMe: isMe,
                          onEdit: () => _showEditDialog(message),
                          onDelete: () => _deleteMessage(message),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildInputArea()),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final glow = cs.primary.withValues(alpha: 0.07);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline),
            boxShadow: [BoxShadow(color: glow, blurRadius: 12)],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.messagesTypeHint,
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    style: TextStyle(color: cs.onSurface, fontSize: 15),
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (text) {
                      setState(() {}); // toggle send button state
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Observer(
                  builder: (_) {
                    final isSending = _store.isSendingMessage;
                    final hasText = _messageController.text.trim().isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasText
                            ? cs.primary
                            : cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                size: 18,
                                color: hasText
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                        onPressed: hasText && !isSending ? _sendMessage : null,
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {}); // Update send button state
    _store.sendMessage(text).then((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();
    setState(() {});
    await _store.sendImage(
      filePath: file.path,
      text: text.isEmpty ? null : text,
    );
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEditDialog(MessageEntity message) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: message.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.messagesEdit),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '...'),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                _store.updateMessage(message.id, newText);
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageEntity message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.messagesDeleteConfirm),
        content: Text(l10n.messagesDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _store.deleteMessage(message.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Builds display list: messages interleaved with DateTime separators.
  /// Since ListView is reverse:true, items[0]=newest(bottom), last=oldest(top).
  /// A DateTime item marks the start of a date group (renders above that group).
  List<Object> _buildDisplayItems(List<MessageEntity> messages) {
    final result = <Object>[];
    for (int i = 0; i < messages.length; i++) {
      result.add(messages[i]);
      final isLastInGroup = i + 1 >= messages.length ||
          !_sameDay(messages[i].created, messages[i + 1].created);
      if (isLastInGroup) {
        result.add(messages[i].created);
      }
    }
    return result;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    if (diff < 7) {
      const days = [
        'Понедельник', 'Вторник', 'Среда', 'Четверг',
        'Пятница', 'Суббота', 'Воскресенье',
      ];
      return days[date.weekday - 1];
    }
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    if (date.year == now.year) {
      return '${date.day} ${months[date.month - 1]}';
    }
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateToService(String cardId) {
    // Navigate to service details using go_router
    context.push('/service/$cardId');
  }
}

class _DateSeparatorWidget extends StatelessWidget {
  final String label;
  const _DateSeparatorWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: color, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: color, thickness: 1)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrl = message.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final hasText = message.text.trim().isNotEmpty;
    final glow = cs.primary.withValues(alpha: 0.07);

    final token = sl<TokenStorage>().getAccessToken();
    final imageHeaders = token != null
        ? {ApiConstants.headerAccessToken: token}
        : const <String, String>{};

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, top: 4),
        padding: hasImage && !hasText
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isMe
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.surfaceContainerHighest,
                    cs.surface,
                  ],
                ),
                borderRadius: borderRadius,
                border: Border.all(color: cs.outline),
                boxShadow: [BoxShadow(color: glow, blurRadius: 8)],
              )
            : BoxDecoration(
                color: cs.surface,
                borderRadius: borderRadius,
                border: Border.all(color: cs.outlineVariant),
              ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onLongPress: isMe ? () => _showOptions(context) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    httpHeaders: imageHeaders,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              if (hasImage && hasText) const SizedBox(height: 8),
              if (hasText)
                _buildTextWithLinks(
                  message.text,
                  TextStyle(color: cs.onSurface, fontSize: 15),
                  cs.primary,
                ),
              Padding(
                padding: hasImage && !hasText
                    ? const EdgeInsets.fromLTRB(8, 4, 8, 6)
                    : const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.created),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (isMe && message.isSeen != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isSeen! ? Icons.done_all : Icons.done,
                          size: 14,
                          color: cs.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: cs.primary),
              title: Text(l10n.messagesEdit),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: cs.error),
              title: Text(
                l10n.delete,
                style: TextStyle(color: cs.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  static final _linkPattern = RegExp(
    r'(korst://[^\s]+|https?://[^\s]+)',
    caseSensitive: false,
  );

  Widget _buildTextWithLinks(
      String text, TextStyle defaultStyle, Color linkColor) {
    final matches = _linkPattern.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: defaultStyle.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.tryParse(url);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.platformDefault);
            }
          },
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
