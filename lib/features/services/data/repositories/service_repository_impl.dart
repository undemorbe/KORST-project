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
      try {
        res = await _api.get(ApiConstants.cardsGetCards, data: {'key': key});
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput = code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(ApiConstants.cardsGetCards, queryParameters: {'key': key});
      }

      final data = res.data;
      if (data is! Map) return CardsPage(cards: const [], nextKey: null);
      final rawCards = data['cards'];
      if (rawCards is! List) return CardsPage(cards: const [], nextKey: null);

      final cards = rawCards.map((e) => _fromCardsListItem(e)).toList();
      final nextKey = cards.isNotEmpty ? cards.last.created.toUtc().toIso8601String() : null;
      return CardsPage(cards: cards, nextKey: nextKey);
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось загрузить карточки');
    }
  }

  @override
  Future<ServiceEntity> getService(String id) async {
    try {
      Response<dynamic> res;
      try {
        res = await _api.get(ApiConstants.cardsCardInfo, data: {'card-id': id});
      } on DioException catch (e) {
        final code = _extractErrorCode(e.response?.data);
        final isInvalidInput = code == ApiErrorCodes.invalidInput || e.response?.statusCode == 400;
        if (!isInvalidInput) rethrow;
        res = await _api.get(ApiConstants.cardsCardInfo, queryParameters: {'card-id': id});
      }

      final data = res.data;
      if (data is! Map) {
        throw ApiException(message: 'Некорректный ответ сервера', statusCode: res.statusCode);
      }

      return _fromCardInfo(data, id);
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось загрузить карточку');
    }
  }

  @override
  Future<void> createService(ServiceEntity service) async {
    final payload = {
      'name': _nullIfEmpty(service.title),
      'description': _nullIfEmpty(service.description),
      'price': service.price,
      'currency': _nullIfEmpty(service.currency),
      'type': _nullIfEmpty(service.type),
      'tags': service.tags,
    };

    try {
      await _api.post(ApiConstants.cardsSaveCard, data: payload);
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось создать карточку');
    }
  }

  @override
  Future<void> updateService(ServiceEntity service) async {
    final payload = {
      'card-id': _nullIfEmpty(service.id),
      'name': _nullIfEmpty(service.title),
      'description': _nullIfEmpty(service.description),
      'price': service.price,
      'currency': _nullIfEmpty(service.currency),
      'type': _nullIfEmpty(service.type),
      'tags': service.tags,
    };

    try {
      await _api.post(ApiConstants.cardsSaveCard, data: payload);
    } on DioException catch (e) {
      throw _toApiException(e, fallbackMessage: 'Не удалось обновить карточку');
    }
  }

  @override
  Future<void> addReview(String serviceId, ReviewEntity review) async {
    return;
  }

  static ServiceEntity _fromCardsListItem(dynamic raw) {
    final Map<String, dynamic> json = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    final id = (json['id'] as String?) ?? '';
    final name = (json['name'] as String?) ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final currency = (json['currency'] as String?) ?? 'USD';
    final type = (json['type'] as String?) ?? 'услуга';
    final tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final created = json['created'] is String ? DateTime.parse(json['created'] as String) : DateTime.now();

    final authorRaw = json['author'];
    UserEntity? author;
    if (authorRaw is Map) {
      final m = Map<String, dynamic>.from(authorRaw);
      final authorId = (m['id'] as String?) ?? (m['uid'] as String?) ?? '';
      final authorPhone = (m['phone'] as String?) ?? '';
      final authorRating = (m['rating'] as num?)?.toDouble();
      author = UserEntity(
        uid: authorId,
        name: (m['name'] as String?) ?? '',
        surname: m['surname'] as String?,
        description: null,
        phone: authorPhone,
        photoUrl: null,
        contacts: {'rating': authorRating},
        createdCards: const [],
        bookings: const {},
        created: DateTime.now(),
        updated: DateTime.now(),
      );
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
      rating: author?.contacts['rating'] is num ? (author!.contacts['rating'] as num).toDouble() : 0.0,
      reviews: const [],
      tags: tags,
      created: created,
      updated: created,
      category: ServiceCategory.other,
      imageUrl: 'https://placehold.co/600x400',
    );
  }

  static ServiceEntity _fromCardInfo(Map data, String id) {
    final json = Map<String, dynamic>.from(data);
    final name = (json['name'] as String?) ?? '';
    final description = (json['description'] as String?) ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final currency = (json['currency'] as String?) ?? 'USD';
    final type = (json['type'] as String?) ?? 'услуга';
    final tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

    final created = json['created'] is String ? DateTime.parse(json['created'] as String) : DateTime.now();
    final updated = json['updated'] is String ? DateTime.parse(json['updated'] as String) : created;

    UserEntity? author;
    final authorRaw = json['author'];
    if (authorRaw is Map) {
      final a = Map<String, dynamic>.from(authorRaw);
      final contactsRaw = a['contacts'];
      final contacts = contactsRaw is Map ? Map<String, dynamic>.from(contactsRaw) : <String, dynamic>{};
      author = UserEntity(
        uid: (a['id'] as String?) ?? '',
        name: (a['name'] as String?) ?? '',
        surname: a['surname'] as String?,
        description: null,
        phone: (a['phone'] as String?) ?? '',
        photoUrl: null,
        contacts: contacts,
        createdCards: const [],
        bookings: const {},
        created: DateTime.now(),
        updated: DateTime.now(),
      );
    }

    double rating = 0.0;
    final ar = author?.contacts['rating'];
    if (ar is num) rating = ar.toDouble();

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
      imageUrl: 'https://placehold.co/600x400',
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
