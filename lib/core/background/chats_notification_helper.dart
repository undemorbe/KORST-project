import '../../../features/messenger/domain/entities/chats_response.dart';
import '../../../features/notifications/notification_service.dart';

class ChatsNotificationHelper {
  const ChatsNotificationHelper._();

  static void compareAndNotify({
    required ChatsResponse oldData,
    required ChatsResponse newData,
    required NotificationService notificationService,
  }) {
    final allNew = [...newData.customerChats, ...newData.merchantChats];
    final allOld = [...oldData.customerChats, ...oldData.merchantChats];

    for (final newChat in allNew) {
      final lastMsg = newChat.lastMessage;
      if (lastMsg == null) continue;
      if (lastMsg.isSeen == true) continue;

      final oldChat = allOld.cast<dynamic>().firstWhere(
        (c) => c.id == newChat.id,
        orElse: () => null,
      );

      final isNewOrChanged =
          oldChat == null || oldChat.lastMessage?.id != lastMsg.id;
      if (!isNewOrChanged) continue;

      final isFromOther = lastMsg.authorId == newChat.user.id;
      if (!isFromOther) continue;

      final senderName = newChat.user.surname != null
          ? '${newChat.user.name} ${newChat.user.surname}'
          : newChat.user.name;

      notificationService.showNotification(
        id: newChat.id.hashCode,
        title: 'Новое сообщение от $senderName',
        body: lastMsg.text.trim().isNotEmpty ? lastMsg.text : 'Изображение',
        payload: newChat.id,
      );
    }
  }
}
