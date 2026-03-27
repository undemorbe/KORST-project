import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

class SafeTalkerDioInterceptor extends Interceptor {
  final Talker _talker;

  SafeTalkerDioInterceptor(this._talker);

  static const _secretKeys = <String>{
    'access-token',
    'refresh-token',
    'otp',
    'password',
    'token',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _talker.info('${options.method} ${options.uri}');
    _talker.debug({
      'headers': _redact(options.headers),
      'query': _redact(options.queryParameters),
      'data': _redact(options.data),
    });
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _talker.info('<= ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
    _talker.debug(_redact(response.data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    _talker.error(
      '<= ERROR ${res?.statusCode ?? ''} ${err.requestOptions.method} ${err.requestOptions.uri}',
      err,
      err.stackTrace,
    );
    _talker.debug(_redact(res?.data));
    handler.next(err);
  }

  dynamic _redact(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((k, v) {
        final key = k.toString();
        if (_secretKeys.contains(key.toLowerCase())) {
          out[key] = '[REDACTED]';
        } else {
          out[key] = _redact(v);
        }
      });
      return out;
    }
    if (value is List) {
      return value.map(_redact).toList();
    }
    if (value is String) {
      return value;
    }
    return value;
  }
}
