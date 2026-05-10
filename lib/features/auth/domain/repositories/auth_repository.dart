import '../entities/auth_user_status.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> sendOtp(String phone);
  Future<AuthUserStatus> checkUser(String phone);
  Future<AuthUserStatus> verifyOtp({
    required String phone,
    required String otp,
  });
  Future<void> logout();
  Future<UserEntity?> getUserProfile();
  Future<void> updateProfile(UserEntity user);
  Future<void> saveLocalProfile(UserEntity user);
  Future<void> refreshAccessToken();
}
