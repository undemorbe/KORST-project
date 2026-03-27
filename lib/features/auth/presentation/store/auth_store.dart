import 'package:mobx/mobx.dart';
import '../../domain/entities/auth_user_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_store.g.dart';

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  final AuthRepository _authRepository;

  _AuthStore(this._authRepository);

  @observable
  bool isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  UserEntity? userProfile;

  @observable
  String? errorMessage;

  @observable
  String? phoneNumber;

  @observable
  AuthUserStatus? userStatus;

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
  Future<void> bootstrap() async {
    isLoading = true;
    errorMessage = null;
    try {
      isLoggedIn = await _authRepository.isLoggedIn();
      userProfile = isLoggedIn ? await _authRepository.getUserProfile() : null;
      final phone = userProfile?.phone;
      if (isLoggedIn && phone != null && phone.isNotEmpty) {
        try {
          userStatus = await _authRepository.checkUser(phone);
          if (userStatus == AuthUserStatus.notFound) {
            await _authRepository.logout();
            isLoggedIn = false;
            userProfile = null;
          }
        } catch (e) {
          errorMessage = e.toString();
          userStatus ??= AuthUserStatus.user;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoggedIn = false;
      userProfile = null;
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
  Future<AuthUserStatus?> verifyOtp(String otp) async {
    isLoading = true;
    errorMessage = null;
    try {
      final phone = phoneNumber;
      if (phone == null) return null;

      final status = await _authRepository.verifyOtp(phone: phone, otp: otp);
      userStatus = status;
      isLoggedIn = status != AuthUserStatus.notFound;
      userProfile = await _authRepository.getUserProfile();
      return status;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> register(String name, String? photoUrl, String contacts) async {
    isLoading = true;
    errorMessage = null;
    try {
      final phone = phoneNumber ?? userProfile?.phone ?? '';
      final base = userProfile ?? UserEntity.empty(phone: phone);
      final updated = base.copyWith(
        name: name,
        photoUrl: photoUrl,
        contacts: {
          ...base.contacts,
          'other': contacts,
        },
        updated: DateTime.now(),
      );
      await _authRepository.updateProfile(updated);
      isLoggedIn = true;
      userProfile = updated;
      userStatus = AuthUserStatus.user;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateProfile(UserEntity user) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _authRepository.updateProfile(user);
      isLoggedIn = true;
      userProfile = user;
      userStatus = AuthUserStatus.user;
      try {
        final phone = user.phone;
        if (phone.isNotEmpty) {
          userStatus = await _authRepository.checkUser(phone);
        }
      } catch (_) {}
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
    userProfile = null;
  }
}
