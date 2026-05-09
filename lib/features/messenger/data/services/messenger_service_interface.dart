import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class MessengerServiceInterface {
  Stream<MessengerSocketEvent> get events;
  
  void start();
  Future<void> stop();
}

class MessengerSocketEvent {
  final String chatId;
  final MessageEntity? message;
  final ChatEntity? chat;

  const MessengerSocketEvent({
    required this.chatId,
    this.message,
    this.chat,
  });
}
