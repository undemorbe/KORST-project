import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../services/domain/entities/service_category.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_review_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiClient _api;

  UserProfileRepositoryImpl(this._api);

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    try {
      final infoRes = await _api.get(ApiConstants.userGetInfo, data: {'user-id': userId});
      final reviewsRes = await _api.get(ApiConstants.userReviews, data: {'user-id': userId});

      final infoData = infoRes.data;
      final reviewsData = reviewsRes.data;

      if (infoData is! Map) {
        throw ApiException(
          message: 'Некорректный ответ сервера',
          statusCode: infoRes.statusCode,
        );
      }

      final info = Map<String, dynamic>.from(infoData);
      final reviewsRaw = reviewsData is Map ? reviewsData['reviews'] : null;
      final reviews = reviewsRaw is List
          ? reviewsRaw
              .map((e) => _mapReview(e))
              .whereType<UserReviewEntity>()
              .toList()
          : <UserReviewEntity>[];

      final cardsRaw = info['cards'];
      final cards = cardsRaw is List
          ? cardsRaw
              .map((e) => _mapCard(e, userId, info['name'] as String? ?? ''))
              .whereType<ServiceEntity>()
              .toList()
          : <ServiceEntity>[];

      final created = info['created'] is String
          ? DateTime.parse(info['created'] as String)
          : DateTime.now();
      final updated = info['updated'] is String
          ? DateTime.parse(info['updated'] as String)
          : created;

      return UserProfileEntity(
        uid: userId,
        name: info['name'] as String? ?? '',
        surname: info['surname'] as String?,
        phone: info['phone'] as String? ?? '',
        description: info['description'] as String?,
        rating: (info['rating'] as num?)?.toDouble() ?? 0,
        contacts: info['contacts'] is Map
            ? Map<String, dynamic>.from(info['contacts'] as Map)
            : <String, dynamic>{},
        created: created,
        updated: updated,
        cards: cards,
        reviews: reviews,
      );
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось загрузить профиль пользователя');
    }
  }

  @override
  Future<void> postReview({
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _api.post(
        ApiConstants.userPostReview,
        data: {
          'user-id': userId,
          'rating': rating,
          'comment': comment.trim(),
        },
      );
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось отправить отзыв');
    }
  }

  UserReviewEntity? _mapReview(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final authorRaw = json['author'];
    final authorJson = authorRaw is Map ? Map<String, dynamic>.from(authorRaw) : const <String, dynamic>{};
    return UserReviewEntity(
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: (json['comment'] as String?) ?? '',
      author: ReviewAuthorEntity(
        name: (authorJson['name'] as String?) ?? 'Пользователь',
        surname: authorJson['surname'] as String?,
        rating: (authorJson['rating'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  ServiceEntity? _mapCard(dynamic raw, String userId, String userName) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final created = json['created'] is String
        ? DateTime.parse(json['created'] as String)
        : DateTime.now();
    final updated = json['updated'] is String
        ? DateTime.parse(json['updated'] as String)
        : created;

    return ServiceEntity(
      uid: (json['id'] as String?) ?? '',
      title: (json['name'] as String?) ?? '',
      description: '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      type: (json['type'] as String?) ?? 'услуга',
      author: UserEntity(
        uid: userId,
        name: userName,
        surname: null,
        description: null,
        phone: '',
        photoUrl: null,
        contacts: const {},
        createdCards: const [],
        bookings: const {},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      timesBooked: 0,
      rating: 0,
      reviews: const [],
      tags: const [],
      created: created,
      updated: updated,
      category: ServiceCategory.other,
      imageUrl: 'https://placehold.co/600x400',
    );
  }

  static ApiException _toApiException(DioException e, {required String fallbackMessage}) {
    final res = e.response;
    final data = res?.data;
    String? code;
    String message = fallbackMessage;

    if (data is Map) {
      final c = data['code'];
      if (c is String) code = c;
      final m = data['message'];
      if (m is String && m.trim().isNotEmpty) message = m;
    }

    return ApiException(message: message, code: code, statusCode: res?.statusCode);
  }
}
