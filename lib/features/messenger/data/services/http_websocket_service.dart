import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:talker/talker.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/token_storage.dart';
import '../../../notifications/notification_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../models/websocket_message.dart';
import 'messenger_service_interface.dart';

class HttpWebSocketService implements MessengerServiceInterface {
  final TokenStorage _tokenStorage;
  final NotificationService _notificationService;
  final Talker _talker;

  final StreamController<WebSocketMessage> _messagesController =
      StreamController<WebSocketMessage>.broadcast();
  
  final StreamController<MessengerSocketEvent> _eventsController =
      StreamController<MessengerSocketEvent>.broadcast();

  StreamSubscription? _subscription;
  bool _isStarted = false;
  bool _isConnected = false;
  Timer? _healthCheckTimer;

  HttpWebSocketService({
    required TokenStorage tokenStorage,
    required NotificationService notificationService,
    required Talker talker,
  }) : _tokenStorage = tokenStorage,
       _notificationService = notificationService,
       _talker = talker;

  @override
  Stream<MessengerSocketEvent> get events => _eventsController.stream;
  Stream<WebSocketMessage> get messages => _messagesController.stream;

  @override
  void start() {
    if (_isStarted) {
      debugPrint('HttpWebSocket: Already started, skipping');
      return;
    }
    debugPrint('HttpWebSocket: Starting connection...');
    _isStarted = true;
    _connect();
  }

  @override
  Future<void> stop() async {
    debugPrint('HttpWebSocket: Stopping connection...');
    _isStarted = false;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _isConnected = false;
    debugPrint('HttpWebSocket: Connection stopped');
  }

  Future<void> _connect() async {
    if (!_isStarted || _isConnected) {
      debugPrint('HttpWebSocket: Connection already active, skipping');
      return;
    }

    final accessToken = _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('HttpWebSocket: No access token available');
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}messenger/websocket');
    final headers = {
      ApiConstants.headerAccessToken: accessToken,
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };

    debugPrint('HttpWebSocket: Connecting to: ${url.toString()}');
    debugPrint('HttpWebSocket: Headers: ${headers.keys.toList()}');

    try {
      final request = http.Request('GET', url);
      request.headers.addAll(headers);
      
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode != 200) {
        throw Exception('HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}');
      }

      _isConnected = true;
      debugPrint('HttpWebSocket: Connection established successfully');
      
      _subscription = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleIncomingData,
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('HttpWebSocket: Stream error - $error');
              _talker.handle(error, stackTrace, 'HttpWebSocket stream error');
              _handleDisconnected();
            },
            onDone: () {
              debugPrint('HttpWebSocket: Stream closed (onDone)');
              _handleDisconnected();
            },
          );

      _startHealthCheck();
      
    } catch (error, stackTrace) {
      debugPrint('HttpWebSocket: Connection failed - $error');
      _talker.handle(error, stackTrace, 'HttpWebSocket connect failed');
      _handleDisconnected();
    }
  }

  void _handleIncomingData(String data) {
    if (data.trim().isEmpty) return;
    
    try {
      final message = WebSocketMessage.fromJson(jsonDecode(data));
      debugPrint('HttpWebSocket: Received message from chat ${message.chatId}');
      
      _messagesController.add(message);
      
      // Convert to MessengerSocketEvent for compatibility
      final event = _convertToSocketEvent(message);
      _eventsController.add(event);
      
      _showIncomingNotification(event);
      
    } catch (error, stackTrace) {
      debugPrint('HttpWebSocket: Failed to parse message - $error');
      _talker.handle(error, stackTrace, 'HttpWebSocket message parse error');
    }
  }

  MessengerSocketEvent _convertToSocketEvent(WebSocketMessage message) {
    // Create a mock MessageEntity from WebSocketMessage
    final messageEntity = MessageEntity(
      id: message.id,
      authorId: message.authorId,
      text: message.text ?? '',
      imageUrl: message.imageURL,
      created: DateTime.tryParse(message.created) ?? DateTime.now(),
      isSeen: message.isSeen,
    );

    // Create a mock ChatEntity with minimal required fields
    final chatEntity = ChatEntity(
      id: message.chatId,
      user: ChatUserInfo(id: '', name: '', surname: ''), // Mock user
      card: CardInfo(id: '', name: ''), // Mock card
    );

    return MessengerSocketEvent(
      chatId: message.chatId,
      message: messageEntity,
      chat: chatEntity,
    );
  }

  void _showIncomingNotification(MessengerSocketEvent event) {
    final message = event.message;
    if (message == null) return;

    final userName = 'User'; // Simplified since we don't have user info
    final body = message.text.trim().isNotEmpty
        ? message.text.trim()
        : message.imageUrl != null
        ? 'Изображение'
        : 'Новое сообщение';

    _notificationService.showNotification(
      id: event.chatId.hashCode & 0x7fffffff,
      title: 'Новое сообщение от $userName',
      body: body,
      payload: event.chatId,
    );
  }

  void _handleDisconnected() {
    _isConnected = false;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _subscription?.cancel();
    _subscription = null;
    
    if (_isStarted) {
      debugPrint('HttpWebSocket: Scheduling reconnect in 5 seconds...');
      Timer(const Duration(seconds: 5), () {
        if (_isStarted) _connect();
      });
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) {
        debugPrint('HttpWebSocket: Health check failed, reconnecting...');
        _handleDisconnected();
      } else {
        debugPrint('HttpWebSocket: Health check passed');
      }
    });
  }

  Future<bool> isChannelAlive() async {
    return _isConnected;
  }
}
