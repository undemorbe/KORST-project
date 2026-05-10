import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final ApiClient _api;

  BannerRepositoryImpl(this._api);

  @override
  Future<List<BannerEntity>> getBanners({int count = 5}) async {
    try {
      final res = await _api.get(
        ApiConstants.bannersGetBanners,
        queryParameters: {'count': count},
      );
      final data = res.data;
      final raw = data is Map ? data['banners'] : null;
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => BannerEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(
        e,
        fallbackMessage: 'Failed to load banners',
      );
    }
  }
}
