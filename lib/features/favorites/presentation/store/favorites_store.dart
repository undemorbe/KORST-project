import 'package:mobx/mobx.dart';
import '../../../../core/storage/local_storage.dart';

part 'favorites_store.g.dart';

class FavoritesStore = _FavoritesStore with _$FavoritesStore;

abstract class _FavoritesStore with Store {
  final LocalStorageService _storageService;
  static const String _favoritesKey = 'favorites';

  _FavoritesStore(this._storageService) {
    _loadFavorites();
  }

  @observable
  ObservableList<String> favoriteIds = ObservableList<String>();

  @action
  void _loadFavorites() {
    final List<dynamic>? stored = _storageService.get(_favoritesKey);
    if (stored != null) {
      favoriteIds = ObservableList.of(stored.cast<String>());
    }
  }

  @action
  Future<void> toggleFavorite(String id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    await _storageService.put(_favoritesKey, favoriteIds.toList());
  }

  bool isFavorite(String id) {
    return favoriteIds.contains(id);
  }
}
