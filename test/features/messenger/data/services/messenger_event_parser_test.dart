import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:korst/features/messenger/data/services/messenger_event_parser.dart';
import 'package:korst/features/messenger/data/services/messenger_socket_service.dart';
import 'package:korst/features/messenger/domain/entities/chat_entity.dart';
import 'package:korst/features/messenger/domain/entities/message_entity.dart';

// ── Minimal stubs ──────────────────────────────────────────────────────────────

class _MsgStub extends MessageEntity {
  _MsgStub({required String authorId, bool? isSeen})
      : super(
          id: 'stub-id',
          authorId: authorId,
          text: '',
          isSeen: isSeen,
          created: DateTime(2026),
        );
}

class _ChatStub extends ChatEntity {
  _ChatStub({required String userId})
      : super(
          id: 'chat-stub',
          user: ChatUserInfo(id: userId, name: 'Test'),
          card: const CardInfo(id: 'card-stub', name: 'Card'),
        );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  Map<String, dynamic> chatMap({String id = 'chat-1'}) => {
        'id': id,
        'user': {
          'id': 'user-1',
          'name': 'Олег',
          'surname': 'Олегов',
          'image-url': 'http://img.example.com/1.png',
        },
        'card': {
          'id': 'card-1',
          'name': 'Услуга',
          'image-url': 'http://img.example.com/card.png',
        },
      };

  Map<String, dynamic> msgMap({
    String id = 'msg-1',
    String authorId = 'user-1',
    String text = 'Привет',
    bool? isSeen,
  }) =>
      {
        'id': id,
        'author-id': authorId,
        'text': text,
        'created': '2026-01-01T10:00:00Z',
        if (isSeen != null) 'is-seen': isSeen,
      };

  group('MessengerEventParser.parse', () {
    test('returns empty list for invalid JSON string', () {
      expect(MessengerEventParser.parse('not json'), isEmpty);
      expect(MessengerEventParser.parse(''), isEmpty);
      expect(MessengerEventParser.parse(null), isEmpty);
    });

    test('parses flat event with chat-id and message', () {
      final raw = jsonEncode({'chat-id': 'chat-1', 'message': msgMap()});

      final events = MessengerEventParser.parse(raw);

      expect(events.length, 1);
      expect(events.first.chatId, 'chat-1');
      expect(events.first.message?.text, 'Привет');
      expect(events.first.message?.authorId, 'user-1');
    });

    test('parses event with camelCase chatId', () {
      final raw = jsonEncode({'chatId': 'chat-99', 'message': msgMap(id: 'msg-99')});

      final events = MessengerEventParser.parse(raw);
      expect(events.first.chatId, 'chat-99');
    });

    test('parses event wrapped in data object', () {
      final raw = jsonEncode({
        'chat-id': 'chat-2',
        'data': {'message': msgMap(id: 'msg-2', text: 'Данные')},
      });

      final events = MessengerEventParser.parse(raw);

      expect(events.length, 1);
      expect(events.first.chatId, 'chat-2');
      expect(events.first.message?.text, 'Данные');
    });

    test('parses chat entity from event', () {
      final raw = jsonEncode({
        'chat-id': 'chat-3',
        'chat': chatMap(id: 'chat-3'),
      });

      final events = MessengerEventParser.parse(raw);

      expect(events.length, 1);
      expect(events.first.chat?.id, 'chat-3');
      expect(events.first.chat?.user.name, 'Олег');
    });

    test('parses array of events', () {
      final raw = jsonEncode([
        {'chat-id': 'chat-1', 'message': msgMap(id: 'msg-1', text: 'Первый')},
        {'chat-id': 'chat-2', 'message': msgMap(id: 'msg-2', text: 'Второй')},
      ]);

      final events = MessengerEventParser.parse(raw);

      expect(events.length, 2);
      expect(events[0].message?.text, 'Первый');
      expect(events[1].message?.text, 'Второй');
    });

    test('ignores event without chat-id', () {
      final raw = jsonEncode({'message': msgMap()});
      expect(MessengerEventParser.parse(raw), isEmpty);
    });

    test('parses imageURL field in message', () {
      final raw = jsonEncode({
        'chat-id': 'chat-1',
        'message': {
          'id': 'msg-img',
          'author-id': 'user-1',
          'imageURL': 'https://img.example.com/photo.png',
          'created': '2026-01-01T10:00:00Z',
        },
      });

      final events = MessengerEventParser.parse(raw);
      expect(events.first.message?.imageUrl, 'https://img.example.com/photo.png');
      expect(events.first.message?.text, '');
    });

    test('parses is-seen field', () {
      final raw = jsonEncode({'chat-id': 'chat-1', 'message': msgMap(isSeen: true)});
      final events = MessengerEventParser.parse(raw);
      expect(events.first.message?.isSeen, true);
    });

    test('uses message-id as id fallback', () {
      final raw = jsonEncode({
        'chat-id': 'chat-1',
        'message': {
          'message-id': 'fallback-id',
          'author-id': 'user-1',
          'text': 'Привет',
          'created': '2026-01-01T10:00:00Z',
        },
      });

      final events = MessengerEventParser.parse(raw);
      expect(events.first.message?.id, 'fallback-id');
    });

    test('accepts raw Map (non-string) input', () {
      final raw = {
        'chat-id': 'chat-map',
        'message': msgMap(id: 'msg-map', text: 'Raw map'),
      };

      final events = MessengerEventParser.parse(raw);
      expect(events.first.chatId, 'chat-map');
      expect(events.first.message?.text, 'Raw map');
    });
  });

  group('MessengerEventParser.isIncoming', () {
    MessengerSocketEvent makeEvent({
      String chatId = 'chat-1',
      String authorId = 'user-1',
      bool? isSeen,
      String? chatUserId,
    }) {
      return MessengerSocketEvent(
        chatId: chatId,
        message: _MsgStub(authorId: authorId, isSeen: isSeen),
        chat: chatUserId != null ? _ChatStub(userId: chatUserId) : null,
      );
    }

    test('incoming when authorId != userId', () {
      expect(MessengerEventParser.isIncoming(makeEvent(authorId: 'user-1'), 'me-123'), isTrue);
    });

    test('outgoing when authorId == userId', () {
      expect(MessengerEventParser.isIncoming(makeEvent(authorId: 'me-123'), 'me-123'), isFalse);
    });

    test('incoming when userId is null and isSeen is null', () {
      expect(MessengerEventParser.isIncoming(makeEvent(isSeen: null), null), isTrue);
    });

    test('outgoing when userId is null and isSeen is true', () {
      expect(MessengerEventParser.isIncoming(makeEvent(isSeen: true), null), isFalse);
    });

    test('returns false when event has no message', () {
      final event = MessengerSocketEvent(chatId: 'chat-1');
      expect(MessengerEventParser.isIncoming(event, 'me'), isFalse);
    });

    test('falls back to chat.user.id when userId is empty — incoming', () {
      final event = makeEvent(authorId: 'user-1', chatUserId: 'user-1');
      expect(MessengerEventParser.isIncoming(event, ''), isTrue);
      expect(MessengerEventParser.isIncoming(event, null), isTrue);
    });

    test('falls back to chat.user.id when userId is empty — outgoing', () {
      final event = makeEvent(authorId: 'me-id', chatUserId: 'user-1');
      expect(MessengerEventParser.isIncoming(event, null), isFalse);
    });
  });
}
