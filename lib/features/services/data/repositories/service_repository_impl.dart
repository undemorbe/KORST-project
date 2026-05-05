import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_error_codes.dart';
import '../../../../core/api/api_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/cards_page.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ApiClient _api;

  ServiceRepositoryImpl(this._api);

  @override
  Future<CardsPage> getServices({required String? key}) async {
    try {
      Response<dynamic> res;
      // Only include key parameter if it's not null (for pagination)
      final queryParams = key != null ? {'key': key} : null;
      try {
        res = await _api.get(
          ApiConstants.cardsGetCards,
          queryParameters: queryParams,
        );
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput =
            code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(
          ApiConstants.cardsGetCards,
          data: queryParams,
        );
      }

      final data = res.data;
      if (data is! Map) return CardsPage(cards: const [], nextKey: null);
      final rawCards = data['cards'];
      if (rawCards is! List) return CardsPage(cards: const [], nextKey: null);

      final cards = rawCards.map((e) => _fromCardsListItem(e)).toList();
      final nextKeyFromApi =
          _stringOrNull(data['nextKey']) ??
          _stringOrNull(data['next_key']) ??
          _stringOrNull(data['next-key']) ??
          _stringOrNull(data['key']);
      final nextKey = nextKeyFromApi ??
          (cards.isNotEmpty ? cards.last.created.toUtc().toIso8601String() : null);
      return CardsPage(cards: cards, nextKey: nextKey);
    } on DioException catch (e) {
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to load cards',
      );
    }
  }

  @override
  Future<ServiceEntity> getService(String id) async {
    try {
      Response<dynamic> res;
      try {
        res = await _api.get(
          ApiConstants.cardsCardInfo,
          queryParameters: {'card-id': id},
        );
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput =
            code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(
          ApiConstants.cardsCardInfo,
          data: {'card-id': id},
        );
      }

      final data = res.data;
      if (data is! Map) {
        throw ApiException(
          message: 'Invalid server response',
          statusCode: res.statusCode,
        );
      }

      final service = _fromCardInfo(data, id);
      return service;
    } on DioException catch (e) {
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to load card',
      );
    }
  }

  @override
  Future<String?> createService(ServiceEntity service) async {
    final payload = {
        'name': _nullIfEmpty(service.title),
        'description': _nullIfEmpty(service.description),
        'price': service.price.toInt(),
        'currency': _nullIfEmpty(service.currency),
        'type': _nullIfEmpty(service.type),
        'tags': service.tags,
      };

    try {
      final response = await _api.post(
        ApiConstants.cardsSaveCard,
        data: payload,
      );
      final data = response.data;
      if (data is Map) {
        if (data.containsKey('card-id')) return data['card-id']?.toString();
        if (data.containsKey('id')) return data['id']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to create card');
    }
  }

  @override
  Future<void> updateService(ServiceEntity service) async {
    final payload = {
        'card-id': _nullIfEmpty(service.id),
        'name': _nullIfEmpty(service.title),
        'description': _nullIfEmpty(service.description),
        'price': service.price.toInt(),
        'currency': _nullIfEmpty(service.currency),
        'type': _nullIfEmpty(service.type),
        'tags': service.tags,
      };

    try {
      await _api.post(ApiConstants.cardsUpdateCard, data: payload);
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Failed to update card');
    }
  }

  @override
  Future<void> addReview(String serviceId, ReviewEntity review) async {
    return;
  }

  @override
  Future<String> uploadCardImage(String cardId, String filePath) async {
    try {
      final res = await _api.uploadFile(
        ApiConstants.cardsSaveImage,
        filePath: filePath,
        fileFieldName: 'image',
        extraFields: {'card-id': cardId},
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
      throw _toApiException(
        e,
        fallbackMessage: 'Failed to load card image',
      );
    }
  }

  static ServiceEntity _fromCardsListItem(dynamic raw) {
    final Map<String, dynamic> json = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const {};
    final id = (json['id'] as String?) ?? (json['uid'] as String?) ?? '';
    final name = (json['name'] as String?) ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final currency = (json['currency'] as String?) ?? 'USD';
    final type = (json['type'] as String?) ?? 'service';
    final tags =
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[];
    final created = _parseDateTime(json['created']) ?? DateTime.now();
    final updated = _parseDateTime(json['updated']) ?? created;

    final authorRaw = json['author'];
    UserEntity? author;
    if (authorRaw is Map) {
      final m = Map<String, dynamic>.from(authorRaw);
      final authorId = (m['id'] as String?) ?? (m['uid'] as String?) ?? '';
      final authorPhone = (m['phone'] as String?) ?? '';
      final authorRating = (m['rating'] as num?)?.toDouble();
      final authorContactsRaw = m['contacts'];
      final authorContacts = authorContactsRaw is Map
          ? Map<String, dynamic>.from(authorContactsRaw)
          : <String, dynamic>{};
      if (authorRating != null) {
        authorContacts['rating'] = authorRating;
      }
      
      String? authorPhotoUrl =
          _stringOrNull(m['image-url']) ?? _stringOrNull(m['imageUrl']);
      if (authorPhotoUrl != null &&
          authorPhotoUrl.isNotEmpty &&
          !authorPhotoUrl.contains('?v=')) {
        authorPhotoUrl = '$authorPhotoUrl?v=${updated.millisecondsSinceEpoch}';
      }

      author = UserEntity(
        uid: authorId,
        name: (m['name'] as String?) ?? '',
        surname: m['surname'] as String?,
        description: null,
        phone: authorPhone,
        photoUrl: authorPhotoUrl,
        contacts: authorContacts,
        createdCards: const [],
        bookings: const {},
        created: DateTime.now(),
        updated: DateTime.now(),
      );
    }

    String imageUrl =
        _stringOrNull(json['image-url']) ??
        _stringOrNull(json['imageUrl']) ??
        'https://placehold.co/600x400';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://placehold.co/600x400';
    }
    if (imageUrl != 'https://placehold.co/600x400' &&
        !imageUrl.contains('?v=')) {
      imageUrl = '$imageUrl?v=${updated.millisecondsSinceEpoch}';
    }

    // Try to get rating from multiple sources: top-level json, then author.rating
    double rating = 0.0;
    final jsonRating = json['rating'];
    final authorRating = author?.contacts['rating'];
    if (jsonRating is num) {
      rating = jsonRating.toDouble();
    } else if (authorRating is num) {
      rating = authorRating.toDouble();
    }

    return ServiceEntity(
      uid: id,
      title: name,
      description: '',
      price: price,
      currency: currency,
      type: type,
      author: author,
      timesBooked: 0,
      rating: rating,
      reviews: const [],
      tags: tags,
      created: created,
      updated: updated,
      category: ServiceCategory.other,
      imageUrl: imageUrl,
    );
  }

  static ServiceEntity _fromCardInfo(Map data, String id) {
    final json = Map<String, dynamic>.from(data);
    final name = (json['name'] as String?) ?? '';
    final description = (json['description'] as String?) ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final currency = (json['currency'] as String?) ?? 'USD';
    final type = (json['type'] as String?) ?? 'service';
    final tags =
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[];

    final created = _parseDateTime(json['created']) ?? DateTime.now();
    final updated = _parseDateTime(json['updated']) ?? created;

    UserEntity? author;
    final authorRaw = json['author'];
    if (authorRaw is Map) {
      final a = Map<String, dynamic>.from(authorRaw);
      final contactsRaw = a['contacts'];
      final contacts = contactsRaw is Map
          ? Map<String, dynamic>.from(contactsRaw)
          : <String, dynamic>{};
      final authorRating = (a['rating'] as num?)?.toDouble();
      if (authorRating != null) {
        contacts['rating'] = authorRating;
      }
      
      String? authorPhotoUrl =
          _stringOrNull(a['image-url']) ?? _stringOrNull(a['imageUrl']);
      if (authorPhotoUrl != null &&
          authorPhotoUrl.isNotEmpty &&
          !authorPhotoUrl.contains('?v=')) {
        authorPhotoUrl = '$authorPhotoUrl?v=${updated.millisecondsSinceEpoch}';
      }

      author = UserEntity(
        uid: (a['id'] as String?) ?? (a['uid'] as String?) ?? '',
        name: (a['name'] as String?) ?? '',
        surname: a['surname'] as String?,
        description: null,
        phone: (a['phone'] as String?) ?? '',
        photoUrl: authorPhotoUrl,
        contacts: contacts,
        createdCards: const [],
        bookings: const {},
        created: DateTime.now(),
        updated: DateTime.now(),
      );
    }

    double rating = 0.0;
    // Try to get rating from multiple possible sources
    final jsonRating = json['rating'];
    final authorRating = author?.contacts['rating'];
    if (jsonRating is num) {
      rating = jsonRating.toDouble();
    } else if (authorRating is num) {
      rating = authorRating.toDouble();
    }

    String imageUrl =
        _stringOrNull(json['image-url']) ??
        _stringOrNull(json['imageUrl']) ??
        'https://placehold.co/600x400';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://placehold.co/600x400';
    }
    if (imageUrl != 'https://placehold.co/600x400' && !imageUrl.contains('?v=')) {
      imageUrl = '$imageUrl?v=${updated.millisecondsSinceEpoch}';
    }

    return ServiceEntity(
      uid: id,
      title: name,
      description: description,
      price: price,
      currency: currency,
      type: type,
      author: author,
      timesBooked: 0,
      rating: rating,
      reviews: const [],
      tags: tags,
      created: created,
      updated: updated,
      category: ServiceCategory.other,
      imageUrl: imageUrl,
    );
  }

  static String? _nullIfEmpty(String? v) {
    if (v == null) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final v = data['code'];
      return v is String ? v : null;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static String? _stringOrNull(dynamic v) {
    if (v is! String) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
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
