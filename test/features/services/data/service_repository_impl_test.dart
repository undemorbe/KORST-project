import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/api/api_client.dart';
import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/services/data/repositories/service_repository_impl.dart';
import 'package:korst/features/services/domain/entities/service_category.dart';
import 'package:korst/features/services/domain/entities/service_entity.dart';

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
  group('ServiceRepositoryImpl (Cards API)', () {
    late Dio dio;
    late Dio refreshDio;
    late TokenStorage tokenStorage;
    late ApiClient apiClient;
    late ServiceRepositoryImpl repo;

    setUp(() async {
      dio = Dio();
      refreshDio = Dio();
      tokenStorage = TokenStorage(_FakeLocalStorage());
      await tokenStorage.saveTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );
      apiClient = ApiClient(
        dio: dio,
        refreshDio: refreshDio,
        tokenStorage: tokenStorage,
      );
      repo = ServiceRepositoryImpl(apiClient);
    });

    test('getServices parses cards list', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.cardsGetCards);
        expect(options.headers[ApiConstants.headerAuthorization], 'access-1');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');

        return _jsonBody(200, {
          'cards': [
            {
              'id': 'c1',
              'name': 'Service 1',
              'price': 100,
              'currency': 'USD',
              'type': 'задание',
              'author': {'name': 'Oleg', 'surname': 'Olegovich', 'rating': 4.5},
              'tags': ['tag1', 'tag2'],
              'created': '2026-03-16T14:32:10Z',
            },
          ],
        });
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final page = await repo.getServices(key: null);
      expect(page.cards, hasLength(1));
      expect(page.nextKey, isNotNull);
      expect(page.cards.first.id, 'c1');
      expect(page.cards.first.title, 'Service 1');
      expect(page.cards.first.price, 100);
      expect(page.cards.first.currency, 'USD');
      expect(page.cards.first.type, 'задание');
    });

    test('searchServices calls get-with-query with pagination key', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.cardsGetWithQuery);
        expect(options.queryParameters['query'], 'repair');
        expect(options.queryParameters['key'], '2026-03-16T14:32:10Z');
        expect(options.headers[ApiConstants.headerAuthorization], 'access-1');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');

        return _jsonBody(200, {
          'cards': [
            {
              'id': 'c2',
              'name': 'Repair B',
              'price': 200,
              'currency': 'USD',
              'type': 'услуга',
              'author': {'name': 'Oleg'},
              'tags': ['repair'],
              'created': '2026-03-16T15:32:10Z',
            },
          ],
        });
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final page = await repo.searchServices(
        query: 'repair',
        key: '2026-03-16T14:32:10Z',
      );

      expect(page.cards, hasLength(1));
      expect(page.cards.first.id, 'c2');
    });

    test('getService parses card-info', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.cardsCardInfo);
        expect(options.headers[ApiConstants.headerAuthorization], 'access-1');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');

        return _jsonBody(200, {
          'name': 'Наименование услуги',
          'description': 'Описание',
          'price': 100,
          'currency': 'USD',
          'type': 'задание',
          'author': {
            'id': 'u1',
            'name': 'Олег',
            'surname': 'Олегович',
            'phone': '+79123456789',
            'contacts': {
              'email': 'merchant@example.com',
              'telegram': '@merchant',
              'others': {'facebook': 'merchant'},
              'rating': 4.5,
            },
          },
          'tags': ['tag1', 'tag2'],
          'created': '2023-01-01',
          'updated': '2023-01-01',
        });
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final ServiceEntity s = await repo.getService('c1');
      expect(s.id, 'c1');
      expect(s.title, 'Наименование услуги');
      expect(s.description, 'Описание');
      expect(s.author?.uid, 'u1');
      expect(s.author?.phone, '+79123456789');
      expect(s.type, 'задание');
    });

    test('createService sends save-card payload', () async {
      ServiceEntity? received;

      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.cardsSaveCard);
        expect(options.headers[ApiConstants.headerAuthorization], 'access-1');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');

        final data = options.data;
        expect(data, isA<Map>());
        final m = Map<String, dynamic>.from(data as Map);
        expect(m['name'], 'Service 1');
        expect(m['description'], 'Desc');
        expect(m['price'], 100.0);
        expect(m['currency'], 'USD');
        expect(m['type'], 'услуга');
        expect(m['tags'], ['t1', 't2']);
        return _jsonBody(200, {});
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      received = ServiceEntity(
        uid: 'tmp',
        title: 'Service 1',
        description: 'Desc',
        price: 100,
        currency: 'USD',
        type: 'услуга',
        timesBooked: 0,
        rating: 0,
        reviews: const [],
        tags: const ['t1', 't2'],
        created: DateTime.now(),
        updated: DateTime.now(),
        category: ServiceCategory.other,
        imageUrl: '',
      );

      await repo.createService(received);
    });

    test('updateService sends update-card payload with card-id', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.cardsUpdateCard);
        expect(options.headers[ApiConstants.headerAuthorization], 'access-1');

        final data = options.data as Map<String, dynamic>;
        expect(data['card-id'], 'card-123');
        expect(data['name'], 'Updated Service');
        expect(data['description'], 'Updated Desc');
        expect(data['price'], 200.0);
        expect(data['currency'], 'EUR');
        expect(data['type'], 'товар');
        expect(data['tags'], ['tag3']);

        return _jsonBody(200, {});
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final service = ServiceEntity(
        uid: 'card-123',
        title: 'Updated Service',
        description: 'Updated Desc',
        price: 200,
        currency: 'EUR',
        type: 'товар',
        timesBooked: 0,
        rating: 0,
        reviews: const [],
        tags: const ['tag3'],
        created: DateTime.now(),
        updated: DateTime.now(),
        category: ServiceCategory.other,
        imageUrl: 'http://example.com/image.jpg',
      );

      await repo.updateService(service);
    });

    test('createReply sends create-reply payload', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        expect(options.path, ApiConstants.repliesCreateReply);
        expect(options.method, 'POST');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');
        expect(options.data, {'card-id': 'card-123'});
        return _jsonBody(200, {});
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      await repo.createReply('card-123');
    });

    test('executor lifecycle calls documented card endpoints', () async {
      final calls = <String, Map<String, dynamic>>{};

      dio.httpClientAdapter = _Adapter((options) async {
        calls[options.path] = Map<String, dynamic>.from(options.data as Map);
        expect(options.method, 'PUT');
        expect(options.headers[ApiConstants.headerAccessToken], 'access-1');
        return _jsonBody(200, {});
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      await repo.approveExecutor(cardId: 'card-1', executorId: 'user-1');
      await repo.rejectExecutor(cardId: 'card-2', executorId: 'user-2');
      await repo.closeCard(cardId: 'card-3', status: 'completed');

      expect(calls[ApiConstants.repliesApproveExecutor], {
        'card-id': 'card-1',
        'executor-id': 'user-1',
      });
      expect(calls[ApiConstants.repliesRejectExecutor], {
        'card-id': 'card-2',
        'executor-id': 'user-2',
      });
      expect(calls[ApiConstants.repliesClose], {
        'card-id': 'card-3',
        'status': 'completed',
      });
    });

    test('getServices parses image-url from API response', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        return _jsonBody(200, {
          'cards': [
            {
              'id': 'c1',
              'name': 'Service 1',
              'image-url': 'http://example.com/service1.jpg',
              'price': 100,
              'currency': 'USD',
              'type': 'задание',
              'author': {'name': 'Oleg', 'surname': 'Olegovich', 'rating': 4.5},
              'tags': ['tag1'],
              'created': '2026-03-16T14:32:10Z',
            },
          ],
        });
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final page = await repo.getServices(key: null);

      // Image URL should include cache-busting query parameter
      expect(
        page.cards.first.imageUrl,
        startsWith('http://example.com/service1.jpg?v='),
      );
    });

    test('getService parses image-url from card-info response', () async {
      dio.httpClientAdapter = _Adapter((options) async {
        return _jsonBody(200, {
          'name': 'Service Detail',
          'description': 'Desc',
          'image-url': 'http://example.com/detail.jpg',
          'price': 100,
          'currency': 'USD',
          'type': 'услуга',
          'author': {'id': 'u1', 'name': 'Oleg', 'surname': 'Olegovich'},
          'tags': [],
          'created': '2023-01-01',
          'updated': '2023-01-01',
        });
      });
      refreshDio.httpClientAdapter = _Adapter(
        (options) async => _jsonBody(500, {}),
      );

      final service = await repo.getService('c1');

      // Image URL should include cache-busting query parameter
      expect(service.imageUrl, startsWith('http://example.com/detail.jpg?v='));
    });
  });
}
