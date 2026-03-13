import '../../../../features/services/domain/entities/service_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String phone;
  final String? photoUrl;
  final Map<String, dynamic> contacts;
  final List<ServiceEntity> createdCards;
  final Map<String, List<dynamic>> bookings;
  final DateTime created;
  final DateTime updated;

  UserEntity({
    required this.uid,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.contacts,
    required this.createdCards,
    required this.bookings,
    required this.created,
    required this.updated,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photo_url'] as String?,
      contacts: Map<String, dynamic>.from(json['contacts'] ?? {}),
      createdCards: (json['created_cards'] as List<dynamic>?)
              ?.map((e) => ServiceEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bookings: Map<String, List<dynamic>>.from(json['bookings'] ?? {}),
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
      'contacts': contacts,
      'created_cards': createdCards.map((e) => e.toJson()).toList(),
      'bookings': bookings,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
