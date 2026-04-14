import 'package:mobx/mobx.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chats_response.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messenger_repository.dart';

part 'messenger_store.g.dart';

// ignore: library_private_types_in_public_api
class MessengerStore = _MessengerStore with _$MessengerStore;

abstract class _MessengerStore with Store {
  final MessengerRepository _messengerRepository;

  _MessengerStore(this._messengerRepository);

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
      await loadMessages(selectedChat!.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSendingMessage = false;
    }
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

  @action
  void clearError() {
    errorMessage = null;
  }
}
