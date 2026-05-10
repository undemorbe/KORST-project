import '../entities/banner_entity.dart';

abstract class BannerRepository {
  Future<List<BannerEntity>> getBanners({int count = 5});
}
