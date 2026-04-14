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

import '../../../../core/api/token_storage.dart';
import '../../../../core/di/injection_container.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiClient _api;

  UserProfileRepositoryImpl(this._api);

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    try {
      Response<dynamic> infoRes;
      try {
        infoRes = await _api.get(
          ApiConstants.userGetInfo,
          data: {'user-id': userId},
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 400 ||
            (e.response?.data is Map &&
                e.response?.data['code'] == 'INVALID_INPUT')) {
          infoRes = await _api.get(
            ApiConstants.userGetInfo,
            queryParameters: {'user-id': userId},
          );
        } else {
          rethrow;
        }
      }

      final infoData = infoRes.data;

      if (infoData is! Map) {
        throw ApiException(
          message: 'Invalid server response (info)',
          statusCode: infoRes.statusCode,
        );
      }
      final info = Map<String, dynamic>.from(infoData);

      Response<dynamic>? reviewsRes;
      try {
        reviewsRes = await _api.get(
          ApiConstants.userReviews,
          data: {'user-id': userId},
        );
      } on DioException catch (_) {
        try {
          reviewsRes = await _api.get(
            ApiConstants.userReviews,
            queryParameters: {'user-id': userId},
          );
        } catch (_) {
          // Игнорируем ошибку, если отзывы не найдены или user-id некорректен
        }
      } catch (_) {
        // Игнорируем
      }

      final reviewsData = reviewsRes?.data;
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
                .map(
                  (e) => _mapCard(
                    e,
                    userId,
                    info['name'] as String? ?? '',
                    (info['rating'] as num?)?.toDouble() ?? 0,
                  ),
                )
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
        photoUrl: info['image-url'] as String?,
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
      throw _toApiException(e, fallbackMessage: 'Failed to load user profile');
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
        data: {'user-id': userId, 'rating': rating, 'comment': comment.trim()},
      );
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to send review');
    }
  }

  @override
  Future<UserProfileEntity> getOwnProfile() async {
    try {
      final infoRes = await _api.get(ApiConstants.userMe);
      final infoData = infoRes.data;
      if (infoData is! Map) {
        throw ApiException(
          message: 'Invalid server response (info)',
          statusCode: infoRes.statusCode,
        );
      }

      final info = Map<String, dynamic>.from(infoData);
      String parsedUserId =
          (info['user-id'] as String?) ??
          (info['user_id'] as String?) ??
          (info['userId'] as String?) ??
          (info['uid'] as String?) ??
          (info['id'] as String?) ??
          '';

      if (parsedUserId.isEmpty) {
        final cardsRaw = info['cards'];
        if (cardsRaw is List && cardsRaw.isNotEmpty) {
          final firstCard = cardsRaw.first;
          if (firstCard is Map) {
            // First check if the author is directly embedded (some APIs do this)
            final authorRaw = firstCard['author'];
            if (authorRaw is Map) {
              parsedUserId =
                  (authorRaw['id'] as String?) ??
                  (authorRaw['uid'] as String?) ??
                  (authorRaw['user-id'] as String?) ??
                  '';
            }

            // If not, fetch the card info to get our own UUID!
            if (parsedUserId.isEmpty) {
              final cardId = (firstCard['id'] as String?) ?? '';
              if (cardId.isNotEmpty) {
                try {
                  final cardRes = await _api.get(
                    ApiConstants.cardsCardInfo,
                    queryParameters: {'card-id': cardId},
                  );
                  final cardData = cardRes.data;
                  if (cardData is Map && cardData['author'] is Map) {
                    final authorData = cardData['author'] as Map;
                    parsedUserId =
                        (authorData['id'] as String?) ??
                        (authorData['uid'] as String?) ??
                        (authorData['user-id'] as String?) ??
                        '';
                  }
                } catch (_) {
                  // Fallback to data body if query param fails
                  try {
                    final cardRes = await _api.get(
                      ApiConstants.cardsCardInfo,
                      data: {'card-id': cardId},
                    );
                    final cardData = cardRes.data;
                    if (cardData is Map && cardData['author'] is Map) {
                      final authorData = cardData['author'] as Map;
                      parsedUserId =
                          (authorData['id'] as String?) ??
                          (authorData['uid'] as String?) ??
                          (authorData['user-id'] as String?) ??
                          '';
                    }
                  } catch (_) {}
                }
              }
            }
          }
        }
      }

      if (parsedUserId.isEmpty && _api.userId != null) {
        // Fallback to cached API userId only if it doesn't look like a phone number
        if (!_api.userId!.startsWith('+')) {
          parsedUserId = _api.userId!;
        }
      }

      if (parsedUserId.isNotEmpty &&
          (_api.userId == null || _api.userId!.startsWith('+'))) {
        try {
          // If we finally found our real UUID, save it to avoid future issues
          final ts = sl<TokenStorage>();
          await ts.saveUserId(parsedUserId);
        } catch (_) {}
      }

      final userId = parsedUserId;

      Response<dynamic>? reviewsRes;
      try {
        reviewsRes = await _api.get(
          ApiConstants.userReviews,
          data: {'user-id': userId},
        );
      } on DioException catch (_) {
        try {
          reviewsRes = await _api.get(
            ApiConstants.userReviews,
            queryParameters: {'user-id': userId},
          );
        } catch (_) {}
      } catch (_) {}

      final reviewsData = reviewsRes?.data;
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
                .map(
                  (e) => _mapCard(
                    e,
                    userId,
                    info['name'] as String? ?? '',
                    (info['rating'] as num?)?.toDouble() ?? 0,
                  ),
                )
                .whereType<ServiceEntity>()
                .toList()
          : <ServiceEntity>[];

      final created = info['created'] is String
          ? DateTime.parse(info['created'] as String)
          : DateTime.now();
      final updated = info['updated'] is String
          ? DateTime.parse(info['updated'] as String)
          : created;

      String? photoUrl =
          (info['image-url'] as String?) ?? (info['photo_url'] as String?);
      if (photoUrl != null &&
          photoUrl.isNotEmpty &&
          !photoUrl.contains('?v=')) {
        photoUrl = '$photoUrl?v=${updated.millisecondsSinceEpoch}';
      }

      return UserProfileEntity(
        uid: userId,
        name: info['name'] as String? ?? '',
        surname: info['surname'] as String?,
        phone: info['phone'] as String? ?? '',
        photoUrl: photoUrl,
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
      throw _toApiException(e, fallbackMessage: 'Failed to load profile');
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final res = await _api.uploadFile(
        ApiConstants.userSaveImage,
        filePath: filePath,
        fileFieldName: 'image',
      );

      final data = res.data;
      if (data is! Map) {
        throw ApiException(
          message: 'Invalid server response',
          statusCode: res.statusCode,
        );
      }

      final imageUrl = data['image-url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        throw ApiException(
          message: 'Error loading image',
          statusCode: res.statusCode,
        );
      }

      return imageUrl;
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to load image');
    }
  }

  UserReviewEntity? _mapReview(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final authorRaw = json['author'];
    final authorJson = authorRaw is Map
        ? Map<String, dynamic>.from(authorRaw)
        : const <String, dynamic>{};
    return UserReviewEntity(
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: (json['comment'] as String?) ?? '',
      author: ReviewAuthorEntity(
        name: (authorJson['name'] as String?) ?? 'User',
        surname: authorJson['surname'] as String?,
        rating: (authorJson['rating'] as num?)?.toDouble() ?? 0,
        photoUrl: authorJson['image-url'] as String?,
      ),
    );
  }

  ServiceEntity? _mapCard(
    dynamic raw,
    String userId,
    String userName,
    double userRating,
  ) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final created = json['created'] is String
        ? DateTime.parse(json['created'] as String)
        : DateTime.now();
    final updated = json['updated'] is String
        ? DateTime.parse(json['updated'] as String)
        : created;

    String imageUrl =
        (json['image-url'] as String?) ?? 'https://placehold.co/600x400';
    if (imageUrl != 'https://placehold.co/600x400' &&
        !imageUrl.contains('?v=')) {
      imageUrl = '$imageUrl?v=${updated.millisecondsSinceEpoch}';
    }

    return ServiceEntity(
      uid: (json['id'] as String?) ?? '',
      title: (json['name'] as String?) ?? '',
      description: '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      type: (json['type'] as String?) ?? 'service',
      author: UserEntity(
        uid: userId,
        name: userName,
        surname: null,
        description: null,
        phone: '',
        photoUrl: null,
        contacts: {'rating': userRating},
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
      imageUrl: imageUrl,
    );
  }

  static ApiException _toApiException(
    DioException e, {
    required String fallbackMessage,
  }) {
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

    return ApiException(
      message: message,
      code: code,
      statusCode: res?.statusCode,
    );
  }
}
