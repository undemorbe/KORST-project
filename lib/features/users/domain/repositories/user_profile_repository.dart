import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<UserProfileEntity> getOwnProfile();
  Future<void> postReview({
    required String userId,
    required double rating,
    required String comment,
  });
  Future<String> uploadProfileImage(String filePath);
}
