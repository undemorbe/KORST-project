class ApiException implements Exception {
  final String? code;
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() {
    final codeStr = code != null ? ' ($code)' : '';
    final statusStr = statusCode != null ? ' [$statusCode]' : '';
    return '$message$codeStr$statusStr';
  }
}

