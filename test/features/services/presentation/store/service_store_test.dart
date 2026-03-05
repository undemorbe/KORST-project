import 'package:flutter_test/flutter_test.dart';
import 'package:korst/features/services/domain/entities/service_category.dart';
import 'package:korst/features/services/domain/entities/service_entity.dart';
import 'package:korst/features/services/domain/usecases/get_services.dart';
import 'package:korst/features/services/presentation/store/service_store.dart';
import 'package:mocktail/mocktail.dart';

class MockGetServices extends Mock implements GetServices {}

void main() {
  late ServiceStore store;
  late MockGetServices mockGetServices;

  final testServices = [
    ServiceEntity(
      id: '1',
      title: 'Cleaning A',
      description: 'Desc A',
      price: 100,
      imageUrl: '',
      category: ServiceCategory.cleaning,
    ),
    ServiceEntity(
      id: '2',
      title: 'Repair B',
      description: 'Desc B',
      price: 200,
      imageUrl: '',
      category: ServiceCategory.repair,
    ),
  ];

  setUp(() {
    mockGetServices = MockGetServices();
    store = ServiceStore(mockGetServices);
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
      when(() => mockGetServices()).thenAnswer((_) async => testServices);

      final future = store.loadServices();
      expect(store.isLoading, true);
      await future;

      expect(store.services, testServices);
      expect(store.isLoading, false);
      expect(store.errorMessage, null);
    });

    test('loadServices failure', () async {
      when(() => mockGetServices()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        throw Exception('Error loading');
      });

      final future = store.loadServices();
      expect(store.isLoading, true);
      await future;

      expect(store.services, isEmpty);
      expect(store.isLoading, false);
      expect(store.errorMessage, isNotNull);
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
