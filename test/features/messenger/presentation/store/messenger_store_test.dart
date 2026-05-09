import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:korst/features/messenger/data/services/messenger_service_interface.dart';
import 'package:korst/features/messenger/data/services/messenger_socket_service.dart';
import 'package:korst/features/messenger/domain/entities/chat_entity.dart';
import 'package:korst/features/messenger/domain/entities/chats_response.dart';
import 'package:korst/features/messenger/domain/entities/message_entity.dart';
import 'package:korst/features/messenger/domain/repositories/messenger_repository.dart';
import 'package:korst/features/messenger/presentation/store/messenger_store.dart';
import 'package:mocktail/mocktail.dart';

class MockMessengerRepository extends Mock implements MessengerRepository {}

class MockMessengerSocketService extends Mock
    implements MessengerSocketService {
  final StreamController<MessengerSocketEvent> _controller =
      StreamController<MessengerSocketEvent>.broadcast();

  @override
  Stream<MessengerSocketEvent> get events => _controller.stream;

  void emit(MessengerSocketEvent event) => _controller.add(event);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMessengerRepository mockRepo;
  late MockMessengerSocketService mockSocket;
  late MessengerStore store;

  final chat1 = ChatEntity(
    id: 'chat-1',
    user: const ChatUserInfo(id: 'user-1', name: 'Олег'),
    lastMessage: LastMessage(
      id: 'msg-0',
      authorId: 'user-1',
      text: 'Привет',
      created: DateTime(2026),
    ),
    card: const CardInfo(id: 'card-1', name: 'Услуга'),
  );

  MessageEntity _msg({
    String id = 'msg-1',
    String authorId = 'user-1',
    String text = 'Новое',
    bool? isSeen,
  }) {
    return MessageEntity(
      id: id,
      authorId: authorId,
      text: text,
      isSeen: isSeen,
      created: DateTime(2026),
    );
  }

  setUp(() {
    mockRepo = MockMessengerRepository();
    mockSocket = MockMessengerSocketService();
    store = MessengerStore(mockRepo, mockSocket);

    when(() => mockRepo.getChats()).thenAnswer((_) async => ChatsResponse(
          merchantChats: [chat1],
          customerChats: [],
        ));
    when(() => mockRepo.getMessages(any())).thenAnswer((_) async => []);
    when(() => mockSocket.start()).thenReturn(null);
    when(() => mockSocket.stop()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await store.stopRealtime();
    await mockSocket._controller.close();
  });

  group('MessengerStore WS event handling', () {
    test('startRealtime subscribes to socket events', () async {
      store.startRealtime();
      verify(() => mockSocket.start()).called(1);
    });

    test('inserts incoming message at index 0 for selected chat', () async {
      await store.loadChats();
      store.selectChat(chat1);
      store.startRealtime();

      final msg = _msg(id: 'new-msg', text: 'Новое сообщение');
      mockSocket.emit(MessengerSocketEvent(chatId: 'chat-1', message: msg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(store.messages.first.id, 'new-msg');
      expect(store.messages.first.text, 'Новое сообщение');
    });

    test('does not insert duplicate message', () async {
      await store.loadChats();
      store.selectChat(chat1);
      store.startRealtime();

      final msg = _msg(id: 'dup-msg');
      mockSocket.emit(MessengerSocketEvent(chatId: 'chat-1', message: msg));
      mockSocket.emit(MessengerSocketEvent(chatId: 'chat-1', message: msg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(store.messages.where((m) => m.id == 'dup-msg').length, 1);
    });

    test('does not insert message for different chat', () async {
      await store.loadChats();
      store.selectChat(chat1);
      store.startRealtime();

      final msg = _msg(id: 'other-msg');
      mockSocket.emit(
          MessengerSocketEvent(chatId: 'chat-other', message: msg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(store.messages.any((m) => m.id == 'other-msg'), isFalse);
    });

    test('updates lastMessage in existing chat on WS event', () async {
      await store.loadChats();
      store.startRealtime();

      final newMsg = _msg(id: 'msg-update', text: 'Обновлённое');
      mockSocket.emit(
          MessengerSocketEvent(chatId: 'chat-1', message: newMsg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updated = store.merchantChats
          .firstWhere((c) => c.id == 'chat-1', orElse: () => chat1);
      expect(updated.lastMessage?.id, 'msg-update');
      expect(updated.lastMessage?.text, 'Обновлённое');
    });

    test('updates selectedChat lastMessage on WS event', () async {
      await store.loadChats();
      store.selectChat(chat1);
      store.startRealtime();

      final newMsg = _msg(id: 'msg-sel', text: 'Для открытого чата');
      mockSocket.emit(MessengerSocketEvent(chatId: 'chat-1', message: newMsg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(store.selectedChat?.lastMessage?.id, 'msg-sel');
    });

    test('reloads chats when WS event has unknown chat-id', () async {
      await store.loadChats();
      store.startRealtime();

      mockSocket.emit(
        MessengerSocketEvent(
          chatId: 'unknown-chat',
          chat: ChatEntity(
            id: 'unknown-chat',
            user: const ChatUserInfo(id: 'u', name: 'X'),
            card: const CardInfo(id: 'c', name: 'Y'),
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // getChats is called once from loadChats + once from needsChatsReload
      verify(() => mockRepo.getChats()).called(greaterThanOrEqualTo(2));
    });

    test('stopRealtime cancels subscription', () async {
      store.startRealtime();
      await store.stopRealtime();

      // Verify stop was called
      verify(() => mockSocket.stop()).called(1);
    });

    test('updates isSeen on lastMessage from WS event', () async {
      await store.loadChats();
      store.startRealtime();

      final msg = _msg(id: 'seen-msg', isSeen: true);
      mockSocket.emit(MessengerSocketEvent(chatId: 'chat-1', message: msg));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updated = store.merchantChats.firstWhere((c) => c.id == 'chat-1');
      expect(updated.lastMessage?.isSeen, true);
    });
  });
}
