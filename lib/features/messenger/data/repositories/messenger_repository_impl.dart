import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_error_codes.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chats_response.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messenger_repository.dart';

class MessengerRepositoryImpl implements MessengerRepository {
  final ApiClient _api;

  MessengerRepositoryImpl(this._api);

  @override
  Future<ChatsResponse> getChats() async {
    try {
      final res = await _api.get(ApiConstants.messengerChats);
      final data = res.data;

      if (data is! Map) {
        throw ApiException(
          message: 'Invalid server response',
          statusCode: res.statusCode,
        );
      }

      final merchantChatsRaw = data['merchant-chats'];
      final customerChatsRaw = data['customer-chats'];

      final merchantChats = merchantChatsRaw is List
          ? merchantChatsRaw
                .map((e) => _mapChat(e))
                .whereType<ChatEntity>()
                .toList()
          : <ChatEntity>[];

      final customerChats = customerChatsRaw is List
          ? customerChatsRaw
                .map((e) => _mapChat(e))
                .whereType<ChatEntity>()
                .toList()
          : <ChatEntity>[];

      final response = ChatsResponse(
        merchantChats: merchantChats,
        customerChats: customerChats,
      );
      
      try {
        sl<LocalStorageService>().put('cache_chats', jsonEncode(response.toJson()));
      } catch (_) {}
      
      return response;
    } on DioException catch (e) {
      try {
        final cachedStr = sl<LocalStorageService>().get('cache_chats') as String?;
        if (cachedStr != null) {
          return ChatsResponse.fromJson(jsonDecode(cachedStr));
        }
      } catch (_) {}
      throw _toApiException(e, fallbackMessage: 'Failed to load chats');
    }
  }

  @override
  Future<List<MessageEntity>> getMessages(String chatId) async {
    try {
      Response<dynamic> res;
      try {
        res = await _api.get(
          ApiConstants.messengerMessages,
          queryParameters: {'chat-id': chatId},
        );
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput =
            code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(
          ApiConstants.messengerMessages,
          data: {'chat-id': chatId},
        );
      }

      final data = res.data;
      if (data is! Map) return <MessageEntity>[];

      final messagesRaw = data['messages'];
      if (messagesRaw is! List) return <MessageEntity>[];

      final messages = messagesRaw
          .map((e) => _mapMessage(e))
          .whereType<MessageEntity>()
          .toList();
          
      try {
        final messagesJson = messages.map((m) => m.toJson()).toList();
        sl<LocalStorageService>().put('cache_messages_$chatId', jsonEncode(messagesJson));
      } catch (_) {}
      
      return messages;
    } on DioException catch (e) {
      try {
        final cachedStr = sl<LocalStorageService>().get('cache_messages_$chatId') as String?;
        if (cachedStr != null) {
          final List<dynamic> decoded = jsonDecode(cachedStr);
          return decoded.map((m) => MessageEntity.fromJson(m)).toList();
        }
      } catch (_) {}
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to load messages',
      );
    }
  }

  @override
  Future<void> createChat({
    required String userId,
    required String cardId,
  }) async {
    try {
      await _api.post(
        ApiConstants.messengerCreateChat,
        data: {'user-id': userId, 'card-id': cardId},
      );
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to create chat');
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      await _api.post(
        ApiConstants.messengerSendMessage,
        data: {'chat-id': chatId, 'text': text.trim()},
      );
    } on DioException catch (e) {
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to send message',
      );
    }
  }

  @override
  Future<void> updateMessage({
    required String messageId,
    required String text,
  }) async {
    try {
      await _api.put(
        ApiConstants.messengerChangeMessage,
        data: {'message-id': messageId, 'text': text.trim()},
      );
    } on DioException catch (e) {
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to edit message',
      );
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _api.delete(
        ApiConstants.messengerDeleteMessage,
        data: {'message-id': messageId},
      );
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to delete message');
    }
  }

  ChatEntity? _mapChat(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);

    final userRaw = json['user'];
    final user = userRaw is Map ? _mapChatUserInfo(userRaw) : null;
    if (user == null) return null;

    final lastMessageRaw = json['last-message'];
    final lastMessage = lastMessageRaw is Map
        ? _mapLastMessage(lastMessageRaw)
        : null;

    final cardRaw = json['card'];
    final card = cardRaw is Map ? _mapCardInfo(cardRaw) : null;
    if (card == null) return null;

    return ChatEntity(
      id: (json['id'] as String?) ?? '',
      user: user,
      lastMessage: lastMessage,
      card: card,
    );
  }

  ChatUserInfo? _mapChatUserInfo(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return ChatUserInfo(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'User',
      surname: json['surname'] as String?,
      imageUrl: json['image-url'] as String?,
    );
  }

  LastMessage? _mapLastMessage(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final created = json['created'] is String
        ? DateTime.parse(json['created'] as String)
        : DateTime.now();
    return LastMessage(
      id: (json['id'] as String?) ?? '',
      authorId: (json['author-id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      created: created,
    );
  }

  CardInfo? _mapCardInfo(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return CardInfo(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      imageUrl: json['image-url'] as String?,
    );
  }

  MessageEntity? _mapMessage(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final created = json['created'] is String
        ? DateTime.parse(json['created'] as String)
        : DateTime.now();
    return MessageEntity(
      id: (json['id'] as String?) ?? '',
      authorId: (json['author-id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      created: created,
    );
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final v = data['code'];
      return v is String ? v : null;
    }
    return null;
  }

  static ApiException _toApiException(
    DioException e, {
    required String fallbackMessage,
  }) {
    final res = e.response;
    final data = res?.data;
    String? code;
    String message = fallbackMessage;

    if (data is Map) {
      final c = data['code'];
      if (c is String) code = c;
      final m = data['message'];
      if (m is String && m.trim().isNotEmpty) message = m;
    }

    return ApiException(
      message: message,
      code: code,
      statusCode: res?.statusCode,
    );
  }
}
