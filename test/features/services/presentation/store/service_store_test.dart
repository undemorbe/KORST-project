import 'package:flutter_test/flutter_test.dart';
import 'package:korst/features/services/domain/entities/cards_page.dart';
import 'package:korst/features/services/domain/entities/review_entity.dart';
import 'package:korst/features/services/domain/entities/service_category.dart';
import 'package:korst/features/services/domain/entities/service_entity.dart';
import 'package:korst/features/services/domain/repositories/service_repository.dart';
import 'package:korst/features/services/presentation/store/service_store.dart';
import 'package:mocktail/mocktail.dart';

class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceStore store;
  late MockServiceRepository mockServiceRepository;

  final testServices = [
    ServiceEntity(
      uid: '1',
      title: 'Cleaning A',
      description: 'Desc A',
      price: 100,
      currency: 'RUB',
      type: 'service',
      timesBooked: 0,
      rating: 0,
      reviews: [],
      tags: [],
      created: DateTime.now(),
      updated: DateTime.now(),
      imageUrl: '',
      category: ServiceCategory.cleaning,
    ),
    ServiceEntity(
      uid: '2',
      title: 'Repair B',
      description: 'Desc B',
      price: 200,
      currency: 'RUB',
      type: 'service',
      timesBooked: 0,
      rating: 0,
      reviews: [],
      tags: [],
      created: DateTime.now(),
      updated: DateTime.now(),
      imageUrl: '',
      category: ServiceCategory.repair,
    ),
  ];

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    store = ServiceStore(mockServiceRepository);
    registerFallbackValue(testServices[0]);
    registerFallbackValue(ReviewEntity(
      uid: 'r1',
      text: 'Good',
      rating: 5,
      created: DateTime.now(),
      updated: DateTime.now(),
    ));
  });

  group('ServiceStore', () {
    test('initial state is correct', () {
      expect(store.services, isEmpty);
      expect(store.isLoading, false);
      expect(store.errorMessage, null);
      expect(store.searchQuery, '');
      expect(store.selectedCategory, null);
    });

    test('loadServices success', () async {
      when(() => mockServiceRepository.getServices(key: any(named: 'key')))
          .thenAnswer((_) async => CardsPage(cards: testServices, nextKey: null));

      await store.loadServices();

      expect(store.services, testServices);
      expect(store.isLoading, false);
      expect(store.errorMessage, null);
    });

    test('loadServices failure', () async {
      when(() => mockServiceRepository.getServices(key: any(named: 'key'))).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        throw Exception('Error loading');
      });

      await store.loadServices();

      expect(store.services, isEmpty);
      expect(store.isLoading, false);
      expect(store.errorMessage, isNotNull);
    });

    test('createService success', () async {
      final newService = testServices[0];
      when(() => mockServiceRepository.createService(any())).thenAnswer((_) async {});
      when(() => mockServiceRepository.getServices(key: any(named: 'key')))
          .thenAnswer((_) async => CardsPage(cards: [newService], nextKey: null));

      await store.createService(newService);

      expect(store.services.length, 1);
      expect(store.services.first, newService);
      expect(store.isLoading, false);
      expect(store.errorMessage, null);
      verify(() => mockServiceRepository.createService(any())).called(1);
      verify(() => mockServiceRepository.getServices(key: any(named: 'key'))).called(1);
    });

    test('addReview success', () async {
      final review = ReviewEntity(
        uid: 'r1',
        text: 'Good',
        rating: 5,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      when(() => mockServiceRepository.addReview(any(), any())).thenAnswer((_) async {});
      when(() => mockServiceRepository.getServices(key: any(named: 'key')))
          .thenAnswer((_) async => CardsPage(cards: testServices, nextKey: null));

      await store.addReview('1', review);

      expect(store.isLoading, false);
      expect(store.errorMessage, null);
      verify(() => mockServiceRepository.addReview('1', any())).called(1);
      verify(() => mockServiceRepository.getServices(key: any(named: 'key'))).called(1);
    });

    test('filtering works correctly', () async {
      store.services.addAll(testServices);

      // No filter
      expect(store.filteredServices.length, 2);

      // Search filter
      store.setSearchQuery('Cleaning');
      expect(store.filteredServices.length, 1);
      expect(store.filteredServices.first.id, '1');

      // Category filter
      store.setSearchQuery('');
      store.setCategory(ServiceCategory.repair);
      expect(store.filteredServices.length, 1);
      expect(store.filteredServices.first.id, '2');

      // Combined
      store.setSearchQuery('Repair');
      store.setCategory(ServiceCategory.repair);
      expect(store.filteredServices.length, 1);

      store.setSearchQuery('Cleaning');
      store.setCategory(ServiceCategory.repair);
      expect(store.filteredServices, isEmpty);
    });
  });
}
