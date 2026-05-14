import '../../../services/domain/entities/service_entity.dart';
import 'user_review_entity.dart';

class RepliesInfoEntity {
  final int total;
  final int accepted;
  final int completed;
  final int failed;

  const RepliesInfoEntity({
    required this.total,
    required this.accepted,
    required this.completed,
    required this.failed,
  });

  factory RepliesInfoEntity.fromJson(Map<String, dynamic> json) {
    return RepliesInfoEntity(
      total: (json['total'] as num?)?.toInt() ?? 0,
      accepted: (json['accepted'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = RepliesInfoEntity(
    total: 0,
    accepted: 0,
    completed: 0,
    failed: 0,
  );
}

class UserProfileEntity {
  final String uid;
  final String name;
  final String? surname;
  final String phone;
  final String? photoUrl;
  final String? description;
  final double rating;
  final Map<String, dynamic> contacts;
  final DateTime created;
  final DateTime updated;
  final List<ServiceEntity> cards;
  final List<UserReviewEntity> reviews;
  final RepliesInfoEntity repliesInfo;

  UserProfileEntity({
    required this.uid,
    required this.name,
    this.surname,
    required this.phone,
    this.photoUrl,
    this.description,
    required this.rating,
    required this.contacts,
    required this.created,
    required this.updated,
    required this.cards,
    required this.reviews,
    this.repliesInfo = RepliesInfoEntity.empty,
  });
}
