import 'package:mobx/mobx.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';

class BannerStore {
  final BannerRepository _repository;

  BannerStore(this._repository);

  final ObservableList<BannerEntity> banners = ObservableList<BannerEntity>();
  final _isLoading = Observable<bool>(false);
  final _errorMessage = Observable<String?>(null);

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<void> loadBanners({int count = 5}) async {
    if (_isLoading.value) return;
    runInAction(() {
      _isLoading.value = true;
      _errorMessage.value = null;
    });
    try {
      final list = await _repository.getBanners(count: count);
      runInAction(() {
        banners.clear();
        banners.addAll(list);
      });
    } catch (e) {
      runInAction(() => _errorMessage.value = e.toString());
    } finally {
      runInAction(() => _isLoading.value = false);
    }
  }
}
