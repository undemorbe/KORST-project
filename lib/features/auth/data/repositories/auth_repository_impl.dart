import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_error_codes.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/auth_user_status.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _userKey = 'user_data';
  static const String _tempPhoneKey = 'temp_phone';

  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl(
    this._api,
    this._tokenStorage,
    this._localStorage,
  );

  @override
  Future<bool> isLoggedIn() async {
    return _tokenStorage.getAccessToken() != null && _tokenStorage.getRefreshToken() != null;
  }

  @override
  Future<void> sendOtp(String phone) async {
    await _localStorage.put(_tempPhoneKey, phone);
    try {
      await _api.post(ApiConstants.authorizeSendOtp, data: {'phone': phone});
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось отправить OTP');
    }
  }

  @override
  Future<AuthUserStatus> checkUser(String phone) async {
    try {
      Response<dynamic> res;
      try {
        res = await _api.get(ApiConstants.authorizeCheckUser, data: {'phone': phone});
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput = code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(ApiConstants.authorizeCheckUser, queryParameters: {'phone': phone});
      }
      final data = res.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final userId = _extractUserId(map);
        if (userId != null) {
          await _cacheUserId(userId: userId, phone: phone);
        }
        return AuthUserStatusX.fromApi(map['status'] as String?);
      }
      return AuthUserStatus.notFound;
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось проверить пользователя');
    }
  }

  @override
  Future<AuthUserStatus> verifyOtp({required String phone, required String otp}) async {
    await _localStorage.put(_tempPhoneKey, phone);
    try {
      final res = await _api.post(
        ApiConstants.authorizeVerifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data = res.data;
      if (data is! Map) {
        throw ApiException(message: 'Некорректный ответ сервера', statusCode: res.statusCode);
      }

      final accessToken = data['access-token'];
      final refreshToken = data['refresh-token'];
      final statusStr = data['status'] as String?;
      final userId = _extractUserId(Map<String, dynamic>.from(data));

      if (accessToken is String && refreshToken is String) {
        await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      if (userId != null) {
        await _tokenStorage.saveUserId(userId);
      }

      final status = AuthUserStatusX.fromApi(statusStr);

      final cached = await getUserProfile();
      final updated = (cached ?? UserEntity.empty(phone: phone)).copyWith(
        uid: userId ?? (cached?.uid),
        phone: phone,
      );
      await _localStorage.put(_userKey, json.encode(updated.toJson()));

      return status;
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось подтвердить OTP');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.authorizeLogout, data: {});
    } catch (_) {}
    await _tokenStorage.clearTokens();
    await _localStorage.delete(_userKey);
    await _localStorage.delete(_tempPhoneKey);
  }

  @override
  Future<UserEntity?> getUserProfile() async {
    final jsonStr = _localStorage.get(_userKey);
    if (jsonStr != null) {
      try {
        if (jsonStr is String) {
          return UserEntity.fromJson(json.decode(jsonStr));
        } else if (jsonStr is Map) {
          return UserEntity.fromJson(Map<String, dynamic>.from(jsonStr));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    final contacts = user.contacts;
    final email = contacts['email'];
    final telegram = contacts['telegram'];
    final others = contacts['others'] ?? contacts['other'];
    Map<String, dynamic>? othersMap;
    if (others is Map && others.isNotEmpty) {
      final raw = Map<String, dynamic>.from(others);
      othersMap = raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      othersMap.removeWhere((key, value) => value.trim().isEmpty);
    } else if (others is String) {
      final s = others.trim();
      if (s.isNotEmpty) {
        othersMap = {'other': s};
      }
    }

    final Map<String, dynamic> request = {
      'name': _nullIfEmpty(user.name),
      'surname': _nullIfEmpty(user.surname),
      'description': _nullIfEmpty(user.description),
      'contacts': {
        'email': _nullIfEmpty(email is String ? email : null),
        'telegram': _nullIfEmpty(telegram is String ? telegram : null),
        'others': othersMap ?? <String, dynamic>{},
      },
    };

    try {
      await _api.post(ApiConstants.userUpdate, data: request);
      await _localStorage.put(_userKey, json.encode(user.toJson()));
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось обновить профиль');
    }
  }

  static String? _nullIfEmpty(String? v) {
    if (v == null) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  static String? _extractUserId(Map<String, dynamic> data) {
    final candidates = [
      data['user-id'],
      data['user_id'],
      data['userId'],
      data['id'],
      data['uid'],
    ];
    for (final value in candidates) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Future<void> _cacheUserId({
    required String userId,
    required String phone,
  }) async {
    await _tokenStorage.saveUserId(userId);
    final cached = await getUserProfile();
    final updated = (cached ?? UserEntity.empty(phone: phone)).copyWith(
      uid: userId,
      phone: phone,
    );
    await _localStorage.put(_userKey, json.encode(updated.toJson()));
  }

  static ApiException _toApiException(DioException e, {required String fallbackMessage}) {
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

  static String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final v = data['code'];
      return v is String ? v : null;
    }
    return null;
  }
}
