import 'dart:async';

import 'package:mobx/mobx.dart';
import '../../data/services/messenger_service_interface.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chats_response.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messenger_repository.dart';

part 'messenger_store.g.dart';

// ignore: library_private_types_in_public_api
class MessengerStore = _MessengerStore with _$MessengerStore;

abstract class _MessengerStore with Store {
  final MessengerRepository _messengerRepository;
  final MessengerServiceInterface _messengerSocketService;
  StreamSubscription<MessengerSocketEvent>? _socketSubscription;

  _MessengerStore(this._messengerRepository, this._messengerSocketService);

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
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
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
          messages = ObservableList.of(msgs);
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
        final exists = messages.any((item) => item.id == message.id);
        if (!exists) {
          messages.insert(0, message);
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
