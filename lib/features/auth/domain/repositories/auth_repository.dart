import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> sendOtp(String phoneNumber);
  Future<bool> verifyOtp(String code);
  Future<void> register(String name, String? photoUrl, String contacts);
  Future<void> logout();
  Future<UserEntity?> getUserProfile();
  Future<void> updateProfile(UserEntity user);
}
