import '../../../auth/domain/entities/user_entity.dart';
import 'review_entity.dart';
import 'service_category.dart';

class ServiceEntity {
  final String uid;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String type;
  final UserEntity?
  author; // Nullable to break circular dependency during serialization/deserialization if needed
  final int timesBooked;
  final double rating;
  final List<ReviewEntity> reviews;
  final List<String> tags;
  final DateTime created;
  final DateTime updated;
  final ServiceCategory category; // Keeping existing field for compatibility
  final String imageUrl; // Keeping existing field for compatibility
  final String? status; // active | in-progress | completed | closed — from /user/me only

  ServiceEntity({
    required this.uid,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
    this.author,
    required this.timesBooked,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.created,
    required this.updated,
    required this.category,
    required this.imageUrl,
    this.status,
  });

  // Alias for id to maintain compatibility
  String get id => uid;

  factory ServiceEntity.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    String normalizeImageUrl(dynamic v) {
      final raw = v is String ? v.trim() : '';
      return raw.isEmpty ? 'https://placehold.co/600x400' : raw;
    }

    return ServiceEntity(
      uid: (json['uid'] as String?) ?? (json['id'] as String?) ?? '',
      title: (json['name'] as String?) ?? (json['title'] as String?) ?? '',
      description: json['description'] as String? ?? '',
      price: toDouble(json['price']) ?? 0.0,
      currency: json['currency'] as String? ?? 'RUB',
      type: json['type'] as String? ?? 'service',
      author:
          json['author'] is Map<String, dynamic>
              ? UserEntity.fromJson(json['author'] as Map<String, dynamic>)
              : null,
      timesBooked: toInt(json['times_booked']) ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      category: json['category'] != null
          ? ServiceCategory.values.firstWhere(
              (e) => e.toString().split('.').last == json['category'],
              orElse: () => ServiceCategory.other)
          : ServiceCategory.other,
      imageUrl: normalizeImageUrl(
        (json['image-url'] as String?) ??
            (json['imageUrl'] as String?) ??
            (json['image_url'] as String?),
      ),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': title,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type,
      'author': author?.toJson(),
      'times_booked': timesBooked,
      'rating': rating,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'tags': tags,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'category': category.toString().split('.').last,
      'image-url': imageUrl,
      'status': status,
    };
  }
}
