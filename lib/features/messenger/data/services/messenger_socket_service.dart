import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:talker/talker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/token_storage.dart';
import '../../../notifications/notification_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import 'messenger_event_parser.dart';

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
    final userId = _tokenStorage.getUserId();
    for (final event in MessengerEventParser.parse(raw)) {
      _eventsController.add(event);
      if (MessengerEventParser.isIncoming(event, userId)) {
        _showIncomingNotification(event);
      }
    }
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
