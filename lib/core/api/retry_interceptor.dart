import 'dart:io';

import 'package:dio/dio.dart';

/// Retries network-level failures (no connectivity, timeout) up to [maxRetries]
/// times with exponential backoff. Does NOT retry server errors (4xx/5xx).
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 2});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isNetworkError(err)) {
      return handler.next(err);
    }

    final retryCount = err.requestOptions.extra['_retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff: 2s, 4s
    await Future<void>.delayed(Duration(seconds: 2 << retryCount));

    final opts = Options(
      method: err.requestOptions.method,
      headers: err.requestOptions.headers,
      contentType: err.requestOptions.contentType,
      responseType: err.requestOptions.responseType,
      validateStatus: err.requestOptions.validateStatus,
      receiveDataWhenStatusError: err.requestOptions.receiveDataWhenStatusError,
      extra: {
        ...err.requestOptions.extra,
        '_retryCount': retryCount + 1,
      },
    );

    try {
      final response = await dio.request<dynamic>(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: opts,
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  static bool _isNetworkError(DioException err) {
    if (err.response != null) return false; // server replied → not network error
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.type == DioExceptionType.unknown && err.error is SocketException);
  }
}
