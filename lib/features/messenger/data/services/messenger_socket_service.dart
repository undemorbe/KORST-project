import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:talker/talker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/token_storage.dart';
import '../../../notifications/notification_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

class MessengerSocketEvent {
  final String chatId;
  final MessageEntity? message;
  final ChatEntity? chat;

  const MessengerSocketEvent({required this.chatId, this.message, this.chat});
}

class MessengerSocketService with WidgetsBindingObserver {
  final TokenStorage _tokenStorage;
  final NotificationService _notificationService;
  final Talker _talker;

  final StreamController<MessengerSocketEvent> _eventsController =
      StreamController<MessengerSocketEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _isStarted = false;
  bool _observerAttached = false;
  int _reconnectAttempt = 0;

  MessengerSocketService({
    required TokenStorage tokenStorage,
    required NotificationService notificationService,
    required Talker talker,
  }) : _tokenStorage = tokenStorage,
       _notificationService = notificationService,
       _talker = talker;

  Stream<MessengerSocketEvent> get events => _eventsController.stream;

  void start() {
    if (_isStarted) return;
    _isStarted = true;
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }
    _connect();
  }

  Future<void> stop() async {
    _isStarted = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _closeConnection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isStarted) return;
    if (state == AppLifecycleState.resumed) {
      _connect();
    } else if (state == AppLifecycleState.detached) {
      unawaited(stop());
    }
  }

  void _connect() {
    if (!_isStarted || _channel != null) return;

    final accessToken = _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _scheduleReconnect();
      return;
    }

    final uri = _socketUri(accessToken);
    final headers = <String, dynamic>{
      ApiConstants.headerAccessToken: accessToken,
      ApiConstants.headerAuthorization: accessToken,
    };
    final userId = _tokenStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      headers[ApiConstants.headerUserId] = userId;
    }

    try {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: headers,
        pingInterval: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 12),
      );
      _subscription = _channel!.stream.listen(
        _handleRawEvent,
        onError: (Object error, StackTrace stackTrace) {
          _talker.handle(error, stackTrace, 'Messenger websocket error');
          _handleDisconnected();
        },
        onDone: _handleDisconnected,
      );
      unawaited(
        _channel!.ready
            .then((_) {
              _reconnectAttempt = 0;
            })
            .catchError((Object error, StackTrace stackTrace) {
              _talker.handle(error, stackTrace, 'Messenger websocket failed');
              _handleDisconnected();
            }),
      );
    } catch (error, stackTrace) {
      _talker.handle(error, stackTrace, 'Messenger websocket connect failed');
      _handleDisconnected();
    }
  }

  Uri _socketUri(String accessToken) {
    final uri = Uri.parse(ApiConstants.messengerSocketUrl);
    final query = Map<String, String>.from(uri.queryParameters);
    query.putIfAbsent(ApiConstants.headerAccessToken, () => accessToken);
    query.putIfAbsent('token', () => accessToken);

    final userId = _tokenStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      query.putIfAbsent(ApiConstants.headerUserId, () => userId);
    }

    return uri.replace(queryParameters: query);
  }

  void _handleRawEvent(dynamic raw) {
    final decoded = _decode(raw);
    if (decoded == null) return;

    for (final event in _parseEvents(decoded)) {
      _eventsController.add(event);
      if (_isIncomingMessage(event)) {
        _showIncomingNotification(event);
      }
    }
  }

  dynamic _decode(dynamic raw) {
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

  Iterable<MessengerSocketEvent> _parseEvents(dynamic decoded) sync* {
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

  bool _looksLikeMessage(Map<String, dynamic> map) {
    return map.containsKey('author-id') ||
        map.containsKey('authorId') ||
        map.containsKey('message-id') ||
        (map.containsKey('id') && map.containsKey('created'));
  }

  bool _looksLikeChat(Map<String, dynamic> map) {
    return map.containsKey('user') && map.containsKey('card');
  }

  MessageEntity? _parseMessage(dynamic raw) {
    final map = _asMap(raw);
    if (map == null || !_looksLikeMessage(map)) return null;

    final normalized = Map<String, dynamic>.from(map);
    normalized['id'] ??= normalized['message-id'] ?? normalized['messageId'];
    normalized['author-id'] ??= normalized['authorId'];
    normalized['created'] ??= DateTime.now().toIso8601String();

    try {
      return MessageEntity.fromJson(normalized);
    } catch (_) {
      return null;
    }
  }

  ChatEntity? _parseChat(dynamic raw) {
    final map = _asMap(raw);
    if (map == null || !_looksLikeChat(map)) return null;

    try {
      return ChatEntity.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _stringValue(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  bool _isIncomingMessage(MessengerSocketEvent event) {
    final message = event.message;
    if (message == null) return false;

    final userId = _tokenStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      return message.authorId != userId;
    }

    final chatUserId = event.chat?.user.id;
    if (chatUserId != null && chatUserId.isNotEmpty) {
      return message.authorId == chatUserId;
    }

    return message.isSeen == null;
  }

  void _showIncomingNotification(MessengerSocketEvent event) {
    final message = event.message;
    if (message == null) return;

    final user = event.chat?.user;
    final userName = user == null
        ? null
        : '${user.name} ${user.surname ?? ''}'.trim();
    final body = message.text.trim().isNotEmpty
        ? message.text.trim()
        : message.imageUrl != null
        ? 'Изображение'
        : 'Новое сообщение';

    unawaited(
      _notificationService.showNotification(
        id: event.chatId.hashCode & 0x7fffffff,
        title: userName == null || userName.isEmpty
            ? 'Новое сообщение'
            : 'Новое сообщение от $userName',
        body: body,
        payload: event.chatId,
      ),
    );
  }

  void _handleDisconnected() {
    unawaited(_closeConnection());
    if (_isStarted) _scheduleReconnect();
  }

  Future<void> _closeConnection() async {
    final subscription = _subscription;
    final channel = _channel;
    _subscription = null;
    _channel = null;
    await subscription?.cancel();
    await channel?.sink.close();
  }

  void _scheduleReconnect() {
    if (!_isStarted || _reconnectTimer != null) return;
    final seconds = _reconnectAttempt < 5 ? 1 << _reconnectAttempt : 30;
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      _connect();
    });
  }
}
