abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> sendOtp(String phoneNumber);
  Future<bool> verifyOtp(String code);
  Future<void> register(String name, String? photoUrl, String contacts);
  Future<void> logout();
  Future<Map<String, String?>> getUserProfile();
}
