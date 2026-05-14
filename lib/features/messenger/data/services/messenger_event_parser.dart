import 'dart:convert';

import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import 'messenger_service_interface.dart';

class MessengerEventParser {
  const MessengerEventParser._();

  static List<MessengerSocketEvent> parse(dynamic raw) {
    final decoded = _decode(raw);
    if (decoded == null) return const [];
    return _parseEvents(decoded).toList();
  }

  static bool isIncoming(MessengerSocketEvent event, String? userId) {
    final message = event.message;
    if (message == null) return false;

    if (userId != null && userId.isNotEmpty) {
      return message.authorId != userId;
    }

    final chatUserId = event.chat?.user.id;
    if (chatUserId != null && chatUserId.isNotEmpty) {
      return message.authorId == chatUserId;
    }

    return message.isSeen == null;
  }

  static dynamic _decode(dynamic raw) {
    if (raw is String) {
      final text = raw.trim();
      if (text.isEmpty) return null;
      try {
        return jsonDecode(text);
      } catch (_) {
        return null;
      }
    }
    return raw;
  }

  static Iterable<MessengerSocketEvent> _parseEvents(dynamic decoded) sync* {
    if (decoded is List) {
      for (final item in decoded) {
        yield* _parseEvents(item);
      }
      return;
    }

    final map = _asMap(decoded);
    if (map == null) return;

    final data = _asMap(map['data']);
    if (data != null && !_looksLikeMessage(map) && !_looksLikeChat(map)) {
      final merged = Map<String, dynamic>.from(data);
      for (final key in const ['chat-id', 'chatId', 'chat_id']) {
        merged.putIfAbsent(key, () => map[key]);
      }
      yield* _parseEvents(merged);
      return;
    }

    final chat =
        _parseChat(map) ??
        _parseChat(map['chat']) ??
        _parseChat(data?['chat']) ??
        _parseChat(data);
    final message =
        _parseMessage(map['message']) ??
        _parseMessage(map['last-message']) ??
        _parseMessage(map['lastMessage']) ??
        _parseMessage(data?['message']) ??
        _parseMessage(data?['last-message']) ??
        _parseMessage(data?['lastMessage']) ??
        _parseMessage(data) ??
        _parseMessage(map);

    final chatId =
        _stringValue(map, const ['chat-id', 'chatId', 'chat_id']) ??
        _stringValue(data, const ['chat-id', 'chatId', 'chat_id']) ??
        chat?.id;
    if (chatId == null || chatId.isEmpty) return;

    yield MessengerSocketEvent(chatId: chatId, message: message, chat: chat);
  }

  static bool _looksLikeMessage(Map<String, dynamic> map) {
    return map.containsKey('author-id') ||
        map.containsKey('authorId') ||
        map.containsKey('message-id') ||
        (map.containsKey('id') && map.containsKey('created'));
  }

  static bool _looksLikeChat(Map<String, dynamic> map) {
    return map.containsKey('user') && map.containsKey('card');
  }

  static MessageEntity? _parseMessage(dynamic raw) {
    final map = _asMap(raw);
    if (map == null || !_looksLikeMessage(map)) return null;
    final normalized = Map<String, dynamic>.from(map);
    normalized['id'] ??= normalized['message-id'] ?? normalized['messageId'];
    normalized['authorId'] ??= normalized['author-id'] ?? normalized['authorId'];
    normalized['imageURL'] ??= normalized['image-url'] ?? normalized['imageUrl'] ?? normalized['image_url'];
    normalized['created'] ??= DateTime.now().toIso8601String();
    try {
      return MessageEntity.fromJson(normalized);
    } catch (_) {
      return null;
    }
  }

  static ChatEntity? _parseChat(dynamic raw) {
    final map = _asMap(raw);
    if (map == null || !_looksLikeChat(map)) return null;
    try {
      return ChatEntity.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static String? _stringValue(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
