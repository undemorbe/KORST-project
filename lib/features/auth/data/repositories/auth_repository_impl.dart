import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/local_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService _localStorage;

  AuthRepositoryImpl(this._localStorage);

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userPhotoKey = 'user_photo';
  static const String _userContactsKey = 'user_contacts';

  @override
  Future<bool> isLoggedIn() async {
    return _localStorage.get(_isLoggedInKey, defaultValue: false);
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    // Save phone number temporarily for later use
    await _localStorage.put(_userPhoneKey, phoneNumber);
  }

  @override
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock logic:
    // '0000' -> Invalid code error
    // '1111' -> Existing user (logs in)
    // Any other code -> New user (needs registration)
    
    if (code == '0000') {
      throw Exception('Неверный код подтверждения');
    }

    if (code == '1111') {
      await _localStorage.put(_isLoggedInKey, true);
      // Mock existing user data
      await _localStorage.put(_userNameKey, 'Иван Иванов');
      await _localStorage.put(_userContactsKey, '@ivan_ivanov');
      return true;
    }
    
    return false;
  }

  @override
  Future<void> register(String name, String? photoUrl, String contacts) async {
    await Future.delayed(const Duration(seconds: 1));
    await _localStorage.put(_isLoggedInKey, true);
    await _localStorage.put(_userNameKey, name);
    if (photoUrl != null) await _localStorage.put(_userPhotoKey, photoUrl);
    await _localStorage.put(_userContactsKey, contacts);
  }

  @override
  Future<void> logout() async {
    await _localStorage.put(_isLoggedInKey, false);
    await _localStorage.delete(_userNameKey);
    await _localStorage.delete(_userPhoneKey);
    await _localStorage.delete(_userPhotoKey);
    await _localStorage.delete(_userContactsKey);
  }

  @override
  Future<Map<String, String?>> getUserProfile() async {
    return {
      'name': _localStorage.get(_userNameKey),
      'phone': _localStorage.get(_userPhoneKey),
      'photoUrl': _localStorage.get(_userPhotoKey),
      'contacts': _localStorage.get(_userContactsKey),
    };
  }
}
