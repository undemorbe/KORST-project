import 'dart:async';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_error_codes.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;

  Future<void>? _refreshing;

  ApiClient({
    required Dio dio,
    required Dio refreshDio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _refreshDio = refreshDio,
        _tokenStorage = tokenStorage {
    _dio.options = _dio.options.copyWith(
      baseUrl: ApiConstants.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    _refreshDio.options = _refreshDio.options.copyWith(
      baseUrl: ApiConstants.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          final accessToken = _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers[ApiConstants.headerAccessToken] = accessToken;
            options.headers[ApiConstants.headerAuthorization] = accessToken;
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final code = _extractErrorCode(err.response?.data);
          final shouldRefresh = code == ApiErrorCodes.accessTokenExpired || err.response?.statusCode == 401;

          if (!shouldRefresh) {
            handler.next(err);
            return;
          }

          final refreshToken = _tokenStorage.getRefreshToken();
          if (refreshToken == null) {
            handler.next(err);
            return;
          }

          try {
            _refreshing ??= _refreshTokens(refreshToken);
            await _refreshing;
          } catch (_) {
            _refreshing = null;
            await _tokenStorage.clearTokens();
            handler.next(err);
            return;
          } finally {
            _refreshing = null;
          }

          final newAccessToken = _tokenStorage.getAccessToken();
          if (newAccessToken == null) {
            handler.next(err);
            return;
          }

          try {
            final response = await _retry(err.requestOptions, newAccessToken);
            handler.resolve(response);
          } catch (e) {
            handler.next(e is DioException ? e : err);
          }
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final v = data['code'];
      return v is String ? v : null;
    }
    return null;
  }

  Future<void> _refreshTokens(String refreshToken) async {
    Response<dynamic> res;
    try {
      res = await _refreshDio.get(
        ApiConstants.authorizeRefresh,
        data: {'refresh-token': refreshToken},
      );
    } on DioException catch (e) {
      final code = _extractErrorCode(e.response?.data);
      final isInvalidInput = code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
      if (!isInvalidInput) rethrow;

      res = await _refreshDio.get(
        ApiConstants.authorizeRefresh,
        queryParameters: {'refresh-token': refreshToken},
      );
    }

    final data = res.data;
    if (data is! Map) {
      throw ApiException(message: 'Ошибка обновления токена', statusCode: res.statusCode);
    }

    final access = data['access-token'];
    final refresh = data['refresh-token'];
    if (access is! String || refresh is! String) {
      throw ApiException(message: 'Ошибка обновления токена', statusCode: res.statusCode);
    }

    await _tokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions, String accessToken) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers[ApiConstants.headerAccessToken] = accessToken;
    headers[ApiConstants.headerAuthorization] = accessToken;

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
