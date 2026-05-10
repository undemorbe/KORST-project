import 'dart:async';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_error_codes.dart';
import 'api_exception.dart';
import 'token_storage.dart';

enum ApiSessionEvent {
  tokensRefreshed,
  sessionExpired,
}

class ApiClient {
  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final StreamController<ApiSessionEvent> _sessionEventsController = StreamController<ApiSessionEvent>.broadcast();

  Future<void>? _refreshing;

  Stream<ApiSessionEvent> get sessionEvents => _sessionEventsController.stream;
  String? get userId => _tokenStorage.getUserId();

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

    _dio.interceptors.insert(
      0,
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          final accessToken = _tokenStorage.getAccessToken();
          final isMe = options.path == ApiConstants.userMe ||
              options.path.endsWith('/${ApiConstants.userMe}');
          final isUserGetInfo = options.path == ApiConstants.userGetInfo ||
              options.path.endsWith('/${ApiConstants.userGetInfo}');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers[ApiConstants.headerAccessToken] = accessToken;
            options.headers[ApiConstants.headerAuthorization] =
                _asAuthorization(accessToken);
          }
          final userId = _tokenStorage.getUserId();
          if (!isMe && !isUserGetInfo && userId != null && userId.isNotEmpty) {
            options.headers[ApiConstants.headerUserId] = userId;
          } else {
            options.headers.remove(ApiConstants.headerUserId);
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final code = _extractErrorCode(err.response?.data);
          final shouldRefresh = code == ApiErrorCodes.accessTokenExpired ||
              code == ApiErrorCodes.refreshTokenExpired ||
              code == 'SESSION_EXPIRED' ||
              err.response?.statusCode == 401;

          if (!shouldRefresh) {
            handler.next(err);
            return;
          }

          if (code == ApiErrorCodes.refreshTokenExpired || code == 'SESSION_EXPIRED') {
            await _tokenStorage.clearTokens();
            _sessionEventsController.add(ApiSessionEvent.sessionExpired);
            handler.next(err);
            return;
          }

          final refreshToken = _tokenStorage.getRefreshToken();
          if (refreshToken == null) {
            await _tokenStorage.clearTokens();
            _sessionEventsController.add(ApiSessionEvent.sessionExpired);
            handler.next(err);
            return;
          }

          try {
            _refreshing ??= _refreshTokens(refreshToken);
            await _refreshing;
          } catch (_) {
            _refreshing = null;
            await _tokenStorage.clearTokens();
            _sessionEventsController.add(ApiSessionEvent.sessionExpired);
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

          // Prevent infinite retry loops by checking if we've already retried this request
          final hasRetried = err.requestOptions.extra['_tokenRetry'] == true;
          if (hasRetried) {
            handler.next(err);
            return;
          }

          try {
            final response = await _retry(
              err.requestOptions,
              newAccessToken,
              markAsRetried: true,
            );
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

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fileFieldName = 'image',
    Map<String, dynamic>? extraFields,
  }) async {
    final formData = FormData.fromMap({
      fileFieldName: await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      ...?extraFields,
    });

    return _dio.post<T>(
      path,
      data: formData,
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
        queryParameters: {'refresh-token': refreshToken},
      );
    } on DioException catch (e) {
      final code = _extractErrorCode(e.response?.data);
      final isInvalidInput = code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
      if (!isInvalidInput) rethrow;

      res = await _refreshDio.get(
        ApiConstants.authorizeRefresh,
        data: {'refresh-token': refreshToken},
      );
    }

    final data = res.data;
    if (data is! Map) {
      throw ApiException(message: 'Error updating token', statusCode: res.statusCode);
    }

    final access = data['access-token'];
    final refresh = data['refresh-token'];
    if (access is! String || refresh is! String) {
      throw ApiException(message: 'Error updating token', statusCode: res.statusCode);
    }

    await _tokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
    _sessionEventsController.add(ApiSessionEvent.tokensRefreshed);
  }

  Future<Response<T>> _retry<T>(
    RequestOptions requestOptions,
    String accessToken, {
    bool markAsRetried = false,
  }) {
    final extra = Map<String, dynamic>.from(requestOptions.extra);
    if (markAsRetried) {
      extra['_tokenRetry'] = true;
    }

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        ApiConstants.headerAccessToken: accessToken,
        ApiConstants.headerAuthorization: _asAuthorization(accessToken),
      },
      extra: extra,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    );
    final isMe = requestOptions.path == ApiConstants.userMe ||
        requestOptions.path.endsWith('/${ApiConstants.userMe}');
    final isUserGetInfo = requestOptions.path == ApiConstants.userGetInfo ||
        requestOptions.path.endsWith('/${ApiConstants.userGetInfo}');
    if (isMe || isUserGetInfo) {
      options.headers?.remove(ApiConstants.headerUserId);
    }

    return _dio.request<T>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static String _asAuthorization(String token) {
    final t = token.trim();
    if (t.isEmpty) return t;
    if (t.toLowerCase().startsWith('bearer ')) {
      return t.substring('bearer '.length).trim();
    }
    return t;
  }
}
