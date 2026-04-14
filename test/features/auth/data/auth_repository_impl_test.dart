import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/api/api_client.dart';
import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/api_error_codes.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:korst/features/auth/domain/entities/auth_user_status.dart';
import 'package:korst/features/auth/domain/entities/user_entity.dart';

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
  group('AuthRepositoryImpl', () {
    late Dio dio;
    late Dio refreshDio;
    late TokenStorage tokenStorage;
    late ApiClient apiClient;
    late AuthRepositoryImpl repo;
    late _FakeLocalStorage localStorage;

    setUp(() async {
      dio = Dio();
      refreshDio = Dio();
      localStorage = _FakeLocalStorage();
      tokenStorage = TokenStorage(localStorage);
      await tokenStorage.saveTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
      apiClient = ApiClient(dio: dio, refreshDio: refreshDio, tokenStorage: tokenStorage);
      repo = AuthRepositoryImpl(apiClient, tokenStorage, localStorage);
    });

    group('sendOtp', () {
      test('sends OTP request with phone number', () async {
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.authorizeSendOtp)) {
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.sendOtp('+79123456789');

        expect(capturedData, isNotNull);
        expect(capturedData!['phone'], '+79123456789');
      });
    });

    group('verifyOtp', () {
      test('verifies OTP and saves tokens', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.authorizeVerifyOtp)) {
            final data = options.data as Map<String, dynamic>?;
            expect(data?['phone'], '+79123456789');
            expect(data?['otp'], '1234');

            return _jsonBody(200, {
              'access-token': 'new-access-token',
              'refresh-token': 'new-refresh-token',
              'status': 'registered',
              'user-id': 'user-123',
            });
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final status = await repo.verifyOtp(phone: '+79123456789', otp: '1234');

        expect(status, AuthUserStatus.user);
        expect(tokenStorage.getAccessToken(), 'new-access-token');
        expect(tokenStorage.getRefreshToken(), 'new-refresh-token');
        expect(tokenStorage.getUserId(), 'user-123');
      });
    });

    group('checkUser', () {
      test('returns user status from API', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.authorizeCheckUser)) {
            final phone = options.queryParameters['phone'] ?? (options.data is String 
                ? jsonDecode(options.data as String)['phone']
                : (options.data as Map<String, dynamic>?)?['phone']);
            expect(phone, '+79123456789');

            return _jsonBody(200, {
              'status': 'registered',
              'user-id': 'user-456',
            });
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final status = await repo.checkUser('+79123456789');

        expect(status, AuthUserStatus.user);
        expect(tokenStorage.getUserId(), 'user-456');
      });

      test('handles notFound status', () async {
        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.authorizeCheckUser)) {
            return _jsonBody(200, {'status': 'notFound'});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        final status = await repo.checkUser('+79999999999');

        expect(status, AuthUserStatus.notFound);
      });
    });

    group('logout', () {
      test('clears tokens and calls logout endpoint', () async {
        bool logoutCalled = false;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.authorizeLogout)) {
            logoutCalled = true;
            expect(options.headers[ApiConstants.headerAuthorization], 'access-1');
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        await repo.logout();

        expect(logoutCalled, true);
        expect(tokenStorage.getAccessToken(), isNull);
        expect(tokenStorage.getRefreshToken(), isNull);
      });
    });

    group('updateProfile', () {
      test('sends profile update with correct payload', () async {
        Map<String, dynamic>? capturedData;

        dio.httpClientAdapter = _Adapter((options) async {
          if (options.path.endsWith(ApiConstants.userUpdate)) {
            capturedData = options.data as Map<String, dynamic>?;
            return _jsonBody(200, {});
          }
          return _jsonBody(404, {'code': ApiErrorCodes.notFound});
        });
        refreshDio.httpClientAdapter = _Adapter((options) async => _jsonBody(500, {}));

        // Create user entity directly
        final user = UserEntity.empty(phone: '+79123456789').copyWith(
          name: 'Original',
          surname: 'Name',
        );
        final updatedUser = user.copyWith(
          name: 'Олег',
          surname: 'Олегов',
          description: 'Тестовое описание',
          contacts: {
            'email': 'oleg@example.com',
            'telegram': '@oleg',
            'others': {'instagram': 'oleg'},
          },
        );

        await repo.updateProfile(updatedUser);

        expect(capturedData, isNotNull);
        expect(capturedData!['name'], 'Олег');
        expect(capturedData!['surname'], 'Олегов');
        expect(capturedData!['description'], 'Тестовое описание');
        expect(capturedData!['contacts']['email'], 'oleg@example.com');
        expect(capturedData!['contacts']['telegram'], '@oleg');
      });
    });

    group('isLoggedIn', () {
      test('returns true when tokens exist', () async {
        final result = await repo.isLoggedIn();
        expect(result, true);
      });

      test('returns false when tokens are missing', () async {
        await tokenStorage.clearTokens();
        final result = await repo.isLoggedIn();
        expect(result, false);
      });
    });
  });
}
