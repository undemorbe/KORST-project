import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/background/chats_notification_helper.dart';
import 'package:korst/features/messenger/domain/entities/chat_entity.dart';
import 'package:korst/features/messenger/domain/entities/chats_response.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/messenger/_helpers/notification_mock.dart';

void main() {
  late MockNotificationService mockNotifications;

  setUp(() {
    mockNotifications = MockNotificationService();
    registerFallbackValue(0);
    registerFallbackValue('');
    when(
      () => mockNotifications.showNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  void compareAndNotify({
    required ChatsResponse oldData,
    required ChatsResponse newData,
  }) {
    ChatsNotificationHelper.compareAndNotify(
      oldData: oldData,
      newData: newData,
      notificationService: mockNotifications,
    );
  }

  ChatEntity _chat({
    String id = 'chat-1',
    String userId = 'user-1',
    String userName = 'Олег',
    String? userSurname = 'Иванов',
    LastMessage? lastMessage,
  }) {
    return ChatEntity(
      id: id,
      user: ChatUserInfo(
        id: userId,
        name: userName,
        surname: userSurname,
      ),
      lastMessage: lastMessage,
      card: const CardInfo(id: 'card-1', name: 'Услуга'),
    );
  }

  LastMessage _msg({
    String id = 'msg-1',
    String authorId = 'user-1',
    String text = 'Привет',
    bool? isSeen,
  }) {
    return LastMessage(
      id: id,
      authorId: authorId,
      text: text,
      created: DateTime(2026),
      isSeen: isSeen,
    );
  }

  group('ChatsNotificationHelper.compareAndNotify', () {
    test('shows notification for new message from other user', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(id: 'msg-old', authorId: 'user-1')),
      ]);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(id: 'msg-new', authorId: 'user-1')),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      final captured = verify(
        () => mockNotifications.showNotification(
          id: captureAny(named: 'id'),
          title: captureAny(named: 'title'),
          body: captureAny(named: 'body'),
          payload: captureAny(named: 'payload'),
        ),
      ).captured;
      expect(captured[1] as String, contains('Олег'));
      expect(captured[2], 'Привет');
      expect(captured[3], 'chat-1');
    });

    test('includes surname in notification title', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: []);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(authorId: 'user-1')),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      final captured = verify(
        () => mockNotifications.showNotification(
          id: captureAny(named: 'id'),
          title: captureAny(named: 'title'),
          body: captureAny(named: 'body'),
          payload: captureAny(named: 'payload'),
        ),
      ).captured;
      expect(captured[1], 'Новое сообщение от Олег Иванов');
    });

    test('no notification when lastMessage.id unchanged', () {
      final msg = _msg(id: 'same-id', authorId: 'user-1');
      final oldData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: msg),
      ]);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: msg),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verifyNever(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('no notification when message is from self (authorId != user.id)', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(id: 'msg-old', authorId: 'user-1')),
      ]);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(id: 'msg-new', authorId: 'self-id')),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verifyNever(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('no notification when isSeen is true', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: []);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(authorId: 'user-1', isSeen: true)),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verifyNever(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('no notification when chat has no lastMessage', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: []);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: null),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verifyNever(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('shows notification for new chat (not in oldData)', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: []);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(id: 'brand-new', lastMessage: _msg(authorId: 'user-1')),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verify(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: 'brand-new',
        ),
      ).called(1);
    });

    test('shows notification for new message in merchant-chats', () {
      final oldData = ChatsResponse(merchantChats: [
        _chat(id: 'merch-1', lastMessage: _msg(id: 'old', authorId: 'user-1')),
      ], customerChats: []);
      final newData = ChatsResponse(merchantChats: [
        _chat(id: 'merch-1', lastMessage: _msg(id: 'new', authorId: 'user-1')),
      ], customerChats: []);

      compareAndNotify(oldData: oldData, newData: newData);

      verify(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: 'merch-1',
        ),
      ).called(1);
    });

    test('shows image placeholder body when text is empty', () {
      final oldData = ChatsResponse(merchantChats: [], customerChats: []);
      final newData = ChatsResponse(merchantChats: [], customerChats: [
        _chat(lastMessage: _msg(authorId: 'user-1', text: '')),
      ]);

      compareAndNotify(oldData: oldData, newData: newData);

      verify(
        () => mockNotifications.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: 'Изображение',
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });
  });
}
