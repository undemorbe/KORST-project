import '../../../../features/services/domain/entities/service_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String? surname;
  final String? description;
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
    this.surname,
    this.description,
    required this.phone,
    this.photoUrl,
    required this.contacts,
    required this.createdCards,
    required this.bookings,
    required this.created,
    required this.updated,
  });

  factory UserEntity.empty({required String phone}) {
    final now = DateTime.now();
    return UserEntity(
      uid: phone,
      name: '',
      surname: null,
      description: null,
      phone: phone,
      photoUrl: null,
      contacts: const {},
      createdCards: const [],
      bookings: const {},
      created: now,
      updated: now,
    );
  }

  UserEntity copyWith({
    String? uid,
    String? name,
    String? surname,
    String? description,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? contacts,
    List<ServiceEntity>? createdCards,
    Map<String, List<dynamic>>? bookings,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      contacts: contacts ?? this.contacts,
      createdCards: createdCards ?? this.createdCards,
      bookings: bookings ?? this.bookings,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: (json['uid'] as String?) ?? (json['id'] as String?) ?? (json['phone'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      surname: json['surname'] as String?,
      description: json['description'] as String?,
      phone: (json['phone'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      contacts: Map<String, dynamic>.from(json['contacts'] ?? {}),
      createdCards: (json['created_cards'] as List<dynamic>?)
              ?.map((e) => ServiceEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bookings: Map<String, List<dynamic>>.from(json['bookings'] ?? {}),
      created: json['created'] is String ? DateTime.parse(json['created'] as String) : DateTime.now(),
      updated: json['updated'] is String ? DateTime.parse(json['updated'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'description': description,
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
