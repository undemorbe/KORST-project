import 'package:korst/core/theme/animated_gradient_background.dart';
import 'package:korst/core/theme/app_colors.dart';
import 'package:korst/core/widgets/glass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
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

  MessengerStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    // Messages are already loaded when chat is selected
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${l10n.errorLoading}: ${_store.errorMessage}',
                            ),
                            ElevatedButton(
                              onPressed: () => _store.loadMessages(chat.id),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
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

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                        top:
                            MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            16,
                        bottom:
                            120, // Increase padding so floating input doesn't cover last message
                        left: 16,
                        right: 16,
                      ),
                      itemCount: _store.messages.length,
                      itemBuilder: (context, index) {
                        final message = _store.messages[index];
                        // Поскольку API /user/me не возвращает id, мы определяем свои сообщения
                        // проверяя, что authorId не равен id собеседника (chat.user.id)
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.surfaceCard, Color(0xFF12100A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: AppColors.goldGlow, blurRadius: 12),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: AppColors.muted,
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
                      fillColor: AppColors.borderSubtle,
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
                      hintStyle: const TextStyle(color: AppColors.muted),
                    ),
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 15,
                    ),
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (text) {
                      setState(() {}); // To toggle send button state
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
                        color: hasText ? AppColors.primary : AppColors.mutedDark,
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
                                    ? const Color(0xFF080604)
                                    : AppColors.muted,
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

  void _navigateToService(String cardId) {
    // Navigate to service details using go_router
    context.push('/service/$cardId');
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
    final imageUrl = message.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final hasText = message.text.trim().isNotEmpty;

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isMe
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.mutedDark, AppColors.surfaceCard],
                ),
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: AppColors.goldGlow, blurRadius: 8),
                ],
              )
            : BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.borderSubtle),
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
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 160,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              if (hasImage && hasText) const SizedBox(height: 8),
              if (hasText)
                _buildTextWithLinks(
                  message.text,
                  TextStyle(
                    color: isMe ? AppColors.primaryLight : AppColors.onSurface,
                    fontSize: 15,
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.created),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    if (isMe && message.isSeen != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isSeen! ? Icons.done_all : Icons.done,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: Text(l10n.messagesEdit),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: AppColors.error),
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

  Widget _buildTextWithLinks(String text, TextStyle defaultStyle) {
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
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
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
