// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavoritesStore on _FavoritesStore, Store {
  late final _$favoriteIdsAtom =
      Atom(name: '_FavoritesStore.favoriteIds', context: context);

  @override
  ObservableList<String> get favoriteIds {
    _$favoriteIdsAtom.reportRead();
    return super.favoriteIds;
  }

  @override
  set favoriteIds(ObservableList<String> value) {
    _$favoriteIdsAtom.reportWrite(value, super.favoriteIds, () {
      super.favoriteIds = value;
    });
  }

  late final _$toggleFavoriteAsyncAction =
      AsyncAction('_FavoritesStore.toggleFavorite', context: context);

  @override
  Future<void> toggleFavorite(String id) {
    return _$toggleFavoriteAsyncAction.run(() => super.toggleFavorite(id));
  }

  late final _$_FavoritesStoreActionController =
      ActionController(name: '_FavoritesStore', context: context);

  @override
  void _loadFavorites() {
    final _$actionInfo = _$_FavoritesStoreActionController.startAction(
        name: '_FavoritesStore._loadFavorites');
    try {
      return super._loadFavorites();
    } finally {
      _$_FavoritesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
favoriteIds: ${favoriteIds}
    ''';
  }
}
