import 'dart:convert';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/local_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService _localStorage;

  AuthRepositoryImpl(this._localStorage);

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userKey = 'user_data';
  static const String _tempPhoneKey = 'temp_phone';

  @override
  Future<bool> isLoggedIn() async {
    return _localStorage.get(_isLoggedInKey, defaultValue: false);
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    await _localStorage.put(_tempPhoneKey, phoneNumber);
  }

  @override
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (code == '0000') {
      throw Exception('Неверный код подтверждения');
    }

    if (code == '1111') {
      await _localStorage.put(_isLoggedInKey, true);
      
      if (_localStorage.get(_userKey) == null) {
        final phone = _localStorage.get(_tempPhoneKey) ?? '+79990000000';
        final user = UserEntity(
          uid: '1234567890',
          name: 'Иван Иванов',
          phone: phone,
          contacts: {
            'email': 'ivan@example.com',
            'telegram': '@ivan_ivanov',
          },
          createdCards: [],
          bookings: {
            'history_of_bookings_as_user': [],
            'history_of_bookings_as_merchant': [],
          },
          created: DateTime(2023, 1, 1),
          updated: DateTime(2023, 1, 1),
        );
        await updateProfile(user);
      }
      return true;
    }
    
    return false;
  }

  @override
  Future<void> register(String name, String? photoUrl, String contactsStr) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final phone = _localStorage.get(_tempPhoneKey) ?? '';
    final user = UserEntity(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      contacts: {
        'other': contactsStr,
      },
      createdCards: [],
      bookings: {
        'history_of_bookings_as_user': [],
        'history_of_bookings_as_merchant': [],
      },
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    await _localStorage.put(_isLoggedInKey, true);
    await updateProfile(user);
  }

  @override
  Future<void> logout() async {
    await _localStorage.put(_isLoggedInKey, false);
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
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    await _localStorage.put(_userKey, json.encode(user.toJson()));
  }
}
