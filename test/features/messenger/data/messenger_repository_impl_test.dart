import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/api/api_client.dart';
import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/api_error_codes.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/messenger/data/repositories/messenger_repository_impl.dart';

class _FakeLocalStorage implements LocalStorageService {
  final Map<String, dynamic> _m = {};

  @override
  Future<void> init() async {}

  @override
  dynamic get(String key, {dynamic defaultValue}) => _m[key] ?? defaultValue;

  @override
  Future<void> put(String key, dynamic value) async => _m[key] = value;

  @override
  Future<void> delete(String key) async => _m.remove(key);

  @override
  Future<void> clear() async => _m.clear();
}

class _Adapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  _Adapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }
}

ResponseBody _jsonBody(int statusCode, Map<String, dynamic> json) {
  return ResponseBody.fromString(
    jsonEncode(json),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('MessengerRepositoryImpl', () {
    late Dio dio;
    late Dio refreshDio;
    late TokenStorage tokenStorage;
    late ApiClient apiClient;
    late MessengerRepositoryImpl repo;

    setUp(() async {
      dio = Dio();
      refreshDio = Dio();
      tokenStorage = TokenStorage(_FakeLocalStorage());
      await tokenStorage.saveTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
      apiClient = ApiClient(dio: dio, refreshDio: refreshDio, tokenStorage: tokenStorage);
      repo = MessengerRepositoryImpl(apiClient);
    });

    group('getChats', () {
      test('parses merchant-chats and customer-chats', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerChats)) {
            return _jsonBody(200, {
              'merchant-chats': [
                {
                  'id': 'chat-1',
                  'user': {
                    'id': 'user-1',
                    'name': 'Покупатель',
                    'surname': 'Петров',
                    'image-url': 'http://example.com/buyer.jpg',
                  },
                  'last-message': {
                    'id': 'msg-1',
                    'author-id': 'user-1',
                    'text': 'Привет, хочу купить',
                    'created': '2026-03-16T14:32:10Z',
                  },
                  'card': {
                    'id': 'card-1',
                    'name': 'Моя услуга',
                    'image-url': 'http://example.com/card.jpg',
                  },
                },
              ],
              'customer-chats': [
                {
                  'id': 'chat-2',
                  'user': {
                    'id': 'user-2',
                    'name': 'Продавец',
                    'surname': 'Иванов',
                    'image-url': 'http://example.com/seller.jpg',
                  },
                  'last-message': {
                    'id': 'msg-2',
                    'author-id': 'me',
                    'text': 'Здравствуйте',
                    'created': '2026-03-16T15:00:00Z',
                  },
                  'card': {
                    'id': 'card-2',
                    'name': 'Услуга продавца',
                    'image-url': 'http://example.com/card2.jpg',
                  },
                },
              ],
            });
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final response = await repo.getChats();

        expect(response.merchantChats.length, 1);
        expect(response.merchantChats.first.user.name, 'Покупатель');
        expect(response.merchantChats.first.card.name, 'Моя услуга');

        expect(response.customerChats.length, 1);
        expect(response.customerChats.first.user.name, 'Продавец');
      });
    });

    group('getMessages', () {
      test('parses messages sorted by descending date', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerMessages)) {
            final qp = options.queryParameters;
            expect(qp['chat-id'], 'chat-123');

            return _jsonBody(200, {
              'messages': [
                {
                  'id': 'msg-3',
                  'author-id': 'user-1',
                  'text': 'Последнее сообщение',
                  'created': '2026-03-16T16:00:00Z',
                },
                {
                  'id': 'msg-2',
                  'author-id': 'me',
                  'text': 'Второе сообщение',
                  'created': '2026-03-16T15:30:00Z',
                },
                {
                  'id': 'msg-1',
                  'author-id': 'user-1',
                  'text': 'Первое сообщение',
                  'created': '2026-03-16T15:00:00Z',
                },
              ],
            });
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final messages = await repo.getMessages('chat-123');

        expect(messages.length, 3);
        expect(messages.first.text, 'Последнее сообщение'); // API returns descending order
        expect(messages.last.text, 'Первое сообщение');
      });
    });

    group('createChat', () {
      test('sends create chat request', () async {
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerCreateChat)) {
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.createChat(userId: 'seller-123', cardId: 'card-456');

        expect(capturedData, isNotNull);
        expect(capturedData!['user-id'], 'seller-123');
        expect(capturedData!['card-id'], 'card-456');
      });
    });

    group('sendMessage', () {
      test('sends message with trimmed text', () async {
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerSendMessage)) {
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.sendMessage(chatId: 'chat-123', text: '  Привет  ');

        expect(capturedData!['chat-id'], 'chat-123');
        expect(capturedData!['text'], 'Привет'); // trimmed
      });
    });

    group('updateMessage', () {
      test('uses PUT method to update message', () async {
        String? capturedMethod;
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerChangeMessage)) {
            capturedMethod = options.method;
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.updateMessage(messageId: 'msg-123', text: 'Новый текст');

        expect(capturedMethod, 'PUT');
        expect(capturedData!['message-id'], 'msg-123');
        expect(capturedData!['text'], 'Новый текст');
      });
    });

    group('deleteMessage', () {
      test('uses DELETE method to delete message', () async {
        String? capturedMethod;
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.messengerDeleteMessage)) {
            capturedMethod = options.method;
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.deleteMessage('msg-123');

        expect(capturedMethod, 'DELETE');
        expect(capturedData!['message-id'], 'msg-123');
      });
    });
  });
}
