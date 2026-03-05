import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/favorites/presentation/store/favorites_store.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;
  late FavoritesStore store;

  setUp(() {
    mockStorage = MockLocalStorageService();
    when(() => mockStorage.get(any())).thenReturn(null);
    store = FavoritesStore(mockStorage);
  });

  group('FavoritesStore', () {
    test('initial state is correct', () {
      expect(store.favoriteIds, isEmpty);
    });

    test('loadFavorites from storage', () {
      when(() => mockStorage.get('favorites')).thenReturn(['1', '2']);
      store = FavoritesStore(mockStorage);
      expect(store.favoriteIds.length, 2);
      expect(store.favoriteIds.contains('1'), true);
    });

    test('toggleFavorite adds and removes', () async {
      when(() => mockStorage.put(any(), any())).thenAnswer((_) async {});

      // Add
      await store.toggleFavorite('1');
      expect(store.favoriteIds.contains('1'), true);
      verify(() => mockStorage.put('favorites', ['1'])).called(1);

      // Remove
      await store.toggleFavorite('1');
      expect(store.favoriteIds.contains('1'), false);
      verify(() => mockStorage.put('favorites', [])).called(1);
    });

    test('isFavorite check', () async {
      when(() => mockStorage.put(any(), any())).thenAnswer((_) async {});
      await store.toggleFavorite('1');
      expect(store.isFavorite('1'), true);
      expect(store.isFavorite('2'), false);
    });
  });
}
