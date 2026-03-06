import 'package:mobx/mobx.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  final AuthRepository _authRepository;

  _AuthStore(this._authRepository);

  @observable
  bool isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  Map<String, String?> userProfile = {};

  @observable
  String? errorMessage;

  @observable
  String? phoneNumber;

  @action
  Future<void> checkLoginStatus() async {
    isLoading = true;
    try {
      isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        userProfile = await _authRepository.getUserProfile();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> sendOtp(String phone) async {
    isLoading = true;
    errorMessage = null;
    phoneNumber = phone;
    try {
      await _authRepository.sendOtp(phone);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> verifyOtp(String code) async {
    isLoading = true;
    errorMessage = null;
    try {
      final exists = await _authRepository.verifyOtp(code);
      if (exists) {
        isLoggedIn = true;
        userProfile = await _authRepository.getUserProfile();
      }
      return exists;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> register(String name, String? photoUrl, String contacts) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _authRepository.register(name, photoUrl, contacts);
      isLoggedIn = true;
      userProfile = await _authRepository.getUserProfile();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> logout() async {
    await _authRepository.logout();
    isLoggedIn = false;
    userProfile = {};
  }
}
