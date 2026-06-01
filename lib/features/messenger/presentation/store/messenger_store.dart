import 'dart:async';

import 'package:mobx/mobx.dart';
import '../../data/services/messenger_event_parser.dart';
import '../../data/services/messenger_service_interface.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chats_response.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messenger_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/storage/local_storage.dart';
import '../../../services/presentation/store/service_store.dart';

part 'messenger_store.g.dart';

// ignore: library_private_types_in_public_api
class MessengerStore = _MessengerStore with _$MessengerStore;

abstract class _MessengerStore with Store {
  final MessengerRepository _messengerRepository;
  final MessengerServiceInterface _messengerSocketService;
  final _LocalUnreadStorage _unreadStorage;
  StreamSubscription<MessengerSocketEvent>? _socketSubscription;

  _MessengerStore(this._messengerRepository, this._messengerSocketService)
      : _unreadStorage = _LocalUnreadStorage(di.sl()) {
    _loadUnreadCounts();
  }

  void _loadUnreadCounts() {
    final saved = _unreadStorage.load();
    if (saved.isNotEmpty) unreadCounts.addAll(saved);
  }

  // Set from outside when user logs in
  String? _myUserId;

  void setMyUserId(String? id) {
    _myUserId = id;
  }

  final ObservableMap<String, int> unreadCounts = ObservableMap<String, int>();

  final Observable<IncomingMessageInfo?> _incomingMessageObs = Observable(null);
  IncomingMessageInfo? get incomingMessage => _incomingMessageObs.value;

  @computed
  int get totalUnreadCount => unreadCounts.values.fold(0, (sum, v) => sum + v);

  @observable
  ObservableList<ChatEntity> merchantChats = ObservableList<ChatEntity>();

  @observable
  ObservableList<ChatEntity> customerChats = ObservableList<ChatEntity>();

  @observable
  ObservableList<MessageEntity> messages = ObservableList<MessageEntity>();

  @observable
  ChatEntity? selectedChat;

  @observable
  bool isLoading = false;

  @observable
  bool isSendingMessage = false;

  @observable
  String? errorMessage;

  @computed
  List<ChatEntity> get allChats => [...merchantChats, ...customerChats];

  @action
  Future<void> loadChats() async {
    isLoading = true;
    errorMessage = null;
    try {
      final ChatsResponse response = await _messengerRepository.getChats();
      merchantChats = ObservableList.of(response.merchantChats);
      customerChats = ObservableList.of(response.customerChats);
      _syncRepliedCardIds();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Sync card IDs from loaded chats → ServiceStore.repliedCardIds
  void _syncRepliedCardIds() {
    try {
      final cardIds = [
        ...merchantChats.map((c) => c.card.id),
        ...customerChats.map((c) => c.card.id),
      ].where((id) => id.isNotEmpty);
      di.sl<ServiceStore>().syncRepliedFromCardIds(cardIds);
    } catch (_) {}
  }

  @action
  Future<void> loadMessages(String chatId) async {
    isLoading = true;
    errorMessage = null;
    try {
      final List<MessageEntity> msgs = await _messengerRepository.getMessages(
        chatId,
      );
      messages = ObservableList.of(msgs);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> createChat({
    required String userId,
    required String cardId,
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _messengerRepository.createChat(userId: userId, cardId: cardId);
      await loadChats();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> sendMessage(String text) async {
    if (selectedChat == null) return;
    isSendingMessage = true;
    errorMessage = null;
    try {
      await _messengerRepository.sendMessage(
        chatId: selectedChat!.id,
        text: text,
      );
      unawaited(_silentRefreshMessages(selectedChat!.id));
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSendingMessage = false;
    }
  }

  @action
  Future<void> sendImage({required String filePath, String? text}) async {
    if (selectedChat == null) return;
    isSendingMessage = true;
    errorMessage = null;
    try {
      await _messengerRepository.sendImage(
        chatId: selectedChat!.id,
        filePath: filePath,
        text: text,
      );
      unawaited(_silentRefreshMessages(selectedChat!.id));
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSendingMessage = false;
    }
  }

  Future<void> _silentRefreshMessages(String chatId) async {
    try {
      final msgs = await _messengerRepository.getMessages(chatId);
      runInAction(() {
        if (selectedChat?.id == chatId) {
          // Merge: preserve imageUrl from existing messages that server hasn't
          // returned yet (image still processing on server side).
          final existing = Map<String, MessageEntity>.fromEntries(
            messages.map((m) => MapEntry(m.id, m)),
          );
          final merged = msgs.map((m) {
            final prev = existing[m.id];
            if (prev != null && m.imageUrl == null && prev.imageUrl != null) {
              return m.copyWith(imageUrl: prev.imageUrl);
            }
            return m;
          }).toList();
          messages = ObservableList.of(merged);
          // Update lastMessage in chat lists so chat list shows current message
          if (msgs.isNotEmpty) {
            final newest = msgs.first; // sorted descending by backend
            final currentChat = selectedChat;
            if (currentChat != null) {
              final updated = currentChat.copyWith(
                lastMessage: LastMessage(
                  id: newest.id,
                  authorId: newest.authorId,
                  text: newest.text,
                  created: newest.created,
                  isSeen: newest.isSeen,
                ),
              );
              _replaceChat(merchantChats, updated);
              _replaceChat(customerChats, updated);
              selectedChat = updated;
            }
          }
        }
      });
    } catch (_) {}
  }

  @action
  Future<void> updateMessage(String messageId, String newText) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _messengerRepository.updateMessage(
        messageId: messageId,
        text: newText,
      );
      if (selectedChat != null) {
        await loadMessages(selectedChat!.id);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteMessage(String messageId) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _messengerRepository.deleteMessage(messageId);
      if (selectedChat != null) {
        await loadMessages(selectedChat!.id);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectChat(ChatEntity? chat) {
    selectedChat = chat;
    if (chat != null) {
      unreadCounts.remove(chat.id);
      _unreadStorage.save(unreadCounts);
      _incomingMessageObs.value = null;
      loadMessages(chat.id);
    } else {
      messages = ObservableList<MessageEntity>();
    }
  }

  Future<bool> selectChatById(String chatId) async {
    var chat = _findChat(chatId);
    if (chat == null) {
      await loadChats();
      chat = _findChat(chatId);
    }
    if (chat == null) return false;
    selectChat(chat);
    return true;
  }

  void startRealtime() {
    _socketSubscription ??= _messengerSocketService.events.listen(
      _handleSocketEvent,
    );
    _messengerSocketService.start();
  }

  Future<void> stopRealtime() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _messengerSocketService.stop();
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  Future<void> _handleSocketEvent(MessengerSocketEvent event) async {
    var needsChatsReload = false;
    runInAction(() {
      final message = event.message;
      if (message != null && selectedChat?.id == event.chatId) {
        final existingIndex = messages.indexWhere((item) => item.id == message.id);
        if (existingIndex == -1) {
          messages.insert(0, message);
        } else if (message.imageUrl != null &&
            messages[existingIndex].imageUrl == null) {
          // WS event brought imageUrl for an already-inserted message — update it
          messages[existingIndex] = message;
        }
      }

      final updated = _chatWithSocketEvent(event);
      if (updated != null) {
        if (selectedChat?.id == updated.id) {
          selectedChat = updated;
        }
        final replaced =
            _replaceChat(merchantChats, updated) ||
            _replaceChat(customerChats, updated);
        needsChatsReload = !replaced && event.chat != null;
      } else if (event.chat != null) {
        needsChatsReload = true;
      }

      // Detect incoming message (not from me, not in current chat)
      final msg = event.message;
      if (msg != null && MessengerEventParser.isIncoming(event, _myUserId)) {
        if (selectedChat?.id != event.chatId) {
          unreadCounts[event.chatId] = (unreadCounts[event.chatId] ?? 0) + 1;
          _unreadStorage.save(unreadCounts);
          final chat = _findChat(event.chatId) ?? event.chat;
          if (chat != null) {
            _incomingMessageObs.value = IncomingMessageInfo(
              chatId: event.chatId,
              senderName:
                  '${chat.user.name}${chat.user.surname != null ? " ${chat.user.surname}" : ""}',
              text: msg.text.trim().isNotEmpty ? msg.text.trim() : '🖼️',
              cardName: chat.card.name,
            );
          }
        }
      }
    });

    if (needsChatsReload) {
      await loadChats();
    }
  }

  ChatEntity? _chatWithSocketEvent(MessengerSocketEvent event) {
    final chat = event.chat ?? _findChat(event.chatId);
    final message = event.message;
    if (chat == null) return null;
    if (message == null) return chat;

    return chat.copyWith(
      lastMessage: LastMessage(
        id: message.id,
        authorId: message.authorId,
        text: message.text,
        created: message.created,
        isSeen: message.isSeen,
      ),
    );
  }

  bool _replaceChat(ObservableList<ChatEntity> chats, ChatEntity updated) {
    final index = chats.indexWhere((chat) => chat.id == updated.id);
    if (index == -1) return false;
    chats[index] = updated;
    return true;
  }

  ChatEntity? _findChat(String chatId) {
    for (final chat in allChats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }
}

class IncomingMessageInfo {
  final String chatId;
  final String senderName;
  final String text;
  final String cardName;

  const IncomingMessageInfo({
    required this.chatId,
    required this.senderName,
    required this.text,
    required this.cardName,
  });
}

// ── Hive persistence for unread counts ───────────────────────────────────────
class _LocalUnreadStorage {
  static const _key = 'chat_unread_counts';
  final LocalStorageService _storage;

  _LocalUnreadStorage(this._storage);

  Map<String, int> load() {
    try {
      final raw = _storage.get(_key, defaultValue: <String, dynamic>{});
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
    } catch (_) {}
    return {};
  }

  void save(Map<String, int> counts) {
    try {
      _storage.put(_key, Map<String, dynamic>.from(counts));
    } catch (_) {}
  }
}
