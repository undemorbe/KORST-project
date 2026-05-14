import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobx/mobx.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _isConnected = Observable<bool>(true);
  bool get isConnected => _isConnected.value;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    runInAction(() => _isConnected.value = _online(result));
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      runInAction(() => _isConnected.value = _online(result));
    });
  }

  bool _online(List<ConnectivityResult> results) =>
      results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);

  void dispose() => _subscription?.cancel();
}
