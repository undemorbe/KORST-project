import '../../../services/domain/entities/service_entity.dart';
import 'user_review_entity.dart';

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
  });
}
