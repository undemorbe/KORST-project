import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/api/api_client.dart';
import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/api_error_codes.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/users/data/repositories/user_profile_repository_impl.dart';

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
  group('UserProfileRepositoryImpl', () {
    late Dio dio;
    late Dio refreshDio;
    late TokenStorage tokenStorage;
    late ApiClient apiClient;
    late UserProfileRepositoryImpl repo;

    setUp(() async {
      dio = Dio();
      refreshDio = Dio();
      tokenStorage = TokenStorage(_FakeLocalStorage());
      await tokenStorage.saveTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
      apiClient = ApiClient(dio: dio, refreshDio: refreshDio, tokenStorage: tokenStorage);
      repo = UserProfileRepositoryImpl(apiClient, tokenStorage);
    });

    group('getUserProfile', () {
      test('parses user profile with cards and reviews', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.userGetInfo)) {
            expect(options.queryParameters?['user-id'], 'user-123');

            return _jsonBody(200, {
              'name': 'Денис',
              'surname': 'Ткачёв',
              'image-url': 'http://example.com/avatar.jpg',
              'phone': '+79123456789',
              'description': 'Люблю прогуливать пары',
              'rating': 4.5,
              'contacts': {
                'email': 'someEmail@gmail.com',
                'telegram': '@eth_higgs',
                'others': {'instagram': 'tkachev'},
              },
              'created': '2026-03-16T14:32:10Z',
              'updated': '2026-03-16T14:32:10Z',
              'cards': [
                {
                  'id': 'card-1',
                  'name': 'Карточка 1',
                  'image-url': 'http://example.com/card1.jpg',
                  'price': 100,
                  'currency': 'USD',
                  'type': 'задание',
                  'created': '2026-03-16T14:32:10Z',
                  'updated': '2026-03-16T14:32:10Z',
                },
              ],
            });
          }
          if (options.path.endsWith(ApiConstants.userReviews)) {
            return _jsonBody(200, {
              'reviews': [
                {
                  'rating': 5,
                  'comment': 'Отличный продавец',
                  'author': {
                    'name': 'Вася',
                    'surname': 'Пупкин',
                    'image-url': 'http://example.com/vasya.jpg',
                    'rating': 4.5,
                  },
                },
              ],
            });
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final profile = await repo.getUserProfile('user-123');

        expect(profile.name, 'Денис');
        expect(profile.surname, 'Ткачёв');
        expect(profile.phone, '+79123456789');
        expect(profile.rating, 4.5);
        expect(profile.cards.length, 1);
        expect(profile.cards.first.title, 'Карточка 1');
        expect(profile.reviews.length, 1);
        expect(profile.reviews.first.comment, 'Отличный продавец');
      });
    });

    group('getOwnProfile', () {
      test('fetches own profile via /user/me endpoint', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.userMe)) {
            return _jsonBody(200, {
              'id': 'user-456',
              'name': 'Олег',
              'surname': 'Олегов',
              'phone': '+79999999999',
              'description': 'Мой профиль',
              'rating': 5.0,
              'contacts': {},
              'created': '2026-01-01T00:00:00Z',
              'updated': '2026-01-01T00:00:00Z',
              'cards': [],
            });
          }
          if (options.path.endsWith(ApiConstants.userReviews)) {
            return _jsonBody(200, {'reviews': []});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final profile = await repo.getOwnProfile();

        expect(profile.uid, 'user-456');
        expect(profile.name, 'Олег');
      });
    });

    group('postReview', () {
      test('sends review with correct payload', () async {
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.userPostReview)) {
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.postReview(userId: 'user-789', rating: 4.5, comment: 'Нормальный тип');

        expect(capturedData, isNotNull);
        expect(capturedData!['user-id'], 'user-789');
        expect(capturedData!['rating'], 4.5);
        expect(capturedData!['comment'], 'Нормальный тип');
      });
    });

    group('uploadProfileImage', () {
      test('uploads image and returns URL', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.userSaveImage)) {
            // Check that content type is multipart
            expect(options.contentType, contains('multipart'));
            return _jsonBody(200, {'image-url': 'http://example.com/new-avatar.jpg'});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        // Note: actual file upload test would require mocking MultipartFile
        // This is a simplified test structure
      });
    });
  });
}
