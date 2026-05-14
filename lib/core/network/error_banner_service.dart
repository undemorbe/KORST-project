import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

class ErrorBannerService {
  final _errorMessage = Observable<String?>(null);
  VoidCallback? _retryCallback;

  String? get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value != null;

  void show(String message, {VoidCallback? onRetry}) {
    _retryCallback = onRetry;
    runInAction(() => _errorMessage.value = message);
  }

  void dismiss() {
    _retryCallback = null;
    runInAction(() => _errorMessage.value = null);
  }

  void retry() {
    final cb = _retryCallback;
    dismiss();
    cb?.call();
  }
}
