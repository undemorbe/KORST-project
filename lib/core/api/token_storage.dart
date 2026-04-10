import '../storage/local_storage.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  final LocalStorageService _storage;

  TokenStorage(this._storage);

  String? getAccessToken() {
    final v = _storage.get(_accessTokenKey);
    return v is String && v.isNotEmpty ? v : null;
  }

  String? getRefreshToken() {
    final v = _storage.get(_refreshTokenKey);
    return v is String && v.isNotEmpty ? v : null;
  }

  String? getUserId() {
    final v = _storage.get(_userIdKey);
    return v is String && v.isNotEmpty ? v : null;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.put(_accessTokenKey, accessToken);
    await _storage.put(_refreshTokenKey, refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return;
    await _storage.put(_userIdKey, id);
  }

  Future<void> clearTokens() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
    await _storage.delete(_userIdKey);
  }
}
