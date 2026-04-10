import 'dart:async';
import 'package:mobx/mobx.dart';
import '../../../../core/api/api_client.dart';
import 'auth_store.dart';

class SessionStore {
  final ApiClient _apiClient;
  final AuthStore _authStore;

  final Observable<bool> _sessionExpired = Observable(false);
  final Observable<int> _eventsVersion = Observable(0);
  StreamSubscription<ApiSessionEvent>? _subscription;
  bool _isHandling = false;

  SessionStore(this._apiClient, this._authStore);

  bool get sessionExpired => _sessionExpired.value;
  int get eventsVersion => _eventsVersion.value;

  void start() {
    _subscription ??= _apiClient.sessionEvents.listen(_onSessionEvent);
  }

  void markHandled() {
    runInAction(() {
      _sessionExpired.value = false;
      _eventsVersion.value++;
    });
  }

  Future<void> _onSessionEvent(ApiSessionEvent event) async {
    if (event == ApiSessionEvent.tokensRefreshed) {
      runInAction(() => _eventsVersion.value++);
      return;
    }
    if (event != ApiSessionEvent.sessionExpired || _isHandling) return;
    _isHandling = true;
    runInAction(() {
      _sessionExpired.value = true;
      _eventsVersion.value++;
    });
    await _authStore.logout();
    _isHandling = false;
  }
}

