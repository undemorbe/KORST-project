import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String? code;
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  static ApiException fromDioException(
    DioException e, {
    required String fallbackMessage,
  }) {
    final res = e.response;
    final data = res?.data;
    String? code;
    String message = fallbackMessage;
    if (data is Map) {
      final c = data['code'];
      if (c is String) code = c;
      final m = data['message'];
      if (m is String && m.trim().isNotEmpty) message = m;
    }
    return ApiException(message: message, code: code, statusCode: res?.statusCode);
  }

  @override
  String toString() {
    final codeStr = code != null ? ' ($code)' : '';
    final statusStr = statusCode != null ? ' [$statusCode]' : '';
    return '$message$codeStr$statusStr';
  }
}
