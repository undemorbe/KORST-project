import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/api/api_client.dart';
import 'package:korst/core/api/api_constants.dart';
import 'package:korst/core/api/api_error_codes.dart';
import 'package:korst/core/api/token_storage.dart';
import 'package:korst/core/storage/local_storage.dart';

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
  group('ApiClient refresh', () {
    test('refreshes token and retries original request', () async {
      final tokenStorage = TokenStorage(_FakeLocalStorage());
      await tokenStorage.saveTokens(accessToken: 'old-access', refreshToken: 'old-refresh');

      final dio = Dio();
      final refreshDio = Dio();

      int protectedCalls = 0;
      String? secondCallHeaderToken;

      dio.httpClientAdapter = _Adapter((options) async {
        if (options.path.endsWith('protected')) {
          protectedCalls += 1;
          if (protectedCalls == 1) {
            return _jsonBody(401, {'code': ApiErrorCodes.accessTokenExpired});
          }
          secondCallHeaderToken = options.headers[ApiConstants.headerAccessToken]?.toString();
          return _jsonBody(200, {'ok': true});
        }
        return _jsonBody(404, {'code': ApiErrorCodes.notFound});
      });

      refreshDio.httpClientAdapter = _Adapter((options) async {
        if (options.path.endsWith(ApiConstants.authorizeRefresh)) {
          return _jsonBody(200, {
            'access-token': 'new-access',
            'refresh-token': 'new-refresh',
          });
        }
        return _jsonBody(404, {'code': ApiErrorCodes.notFound});
      });

      final client = ApiClient(dio: dio, refreshDio: refreshDio, tokenStorage: tokenStorage);

      final res = await client.get('protected');
      expect(res.statusCode, 200);
      expect(res.data, isA<Map>());
      expect((res.data as Map)['ok'], true);
      expect(tokenStorage.getAccessToken(), 'new-access');
      expect(tokenStorage.getRefreshToken(), 'new-refresh');
      expect(protectedCalls, 2);
      expect(secondCallHeaderToken, 'new-access');
    });
  });
}
