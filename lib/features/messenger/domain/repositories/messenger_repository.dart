import '../entities/chats_response.dart';
import '../entities/message_entity.dart';

abstract class MessengerRepository {
  Future<ChatsResponse> getChats();
  Future<List<MessageEntity>> getMessages(String chatId);
  Future<void> createChat({required String userId, required String cardId});
  Future<void> sendMessage({required String chatId, required String text});
  Future<void> sendImage({
    required String chatId,
    required String filePath,
    String? text,
  });
  Future<void> updateMessage({required String messageId, required String text});
  Future<void> deleteMessage(String messageId);
}
