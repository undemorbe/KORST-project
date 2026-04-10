import 'package:mobx/mobx.dart';
import '../../domain/entities/cards_page.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/service_repository.dart';

part 'service_store.g.dart';

// ignore: library_private_types_in_public_api
class ServiceStore = _ServiceStore with _$ServiceStore;

abstract class _ServiceStore with Store {
  final ServiceRepository _serviceRepository;

  _ServiceStore(this._serviceRepository);

  @observable
  ObservableList<ServiceEntity> services = ObservableList<ServiceEntity>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @observable
  ServiceCategory? selectedCategory;

  @observable
  String? nextKey;

  @observable
  bool hasMore = true;

  @computed
  List<ServiceEntity> get filteredServices {
    return services.where((service) {
      final matchesSearch = service.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == null || service.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @action
  Future<void> loadServices() async {
    isLoading = true;
    errorMessage = null;
    try {
      final CardsPage page = await _serviceRepository.getServices(key: null);
      services = ObservableList.of(page.cards);
      nextKey = page.nextKey;
      hasMore = page.nextKey != null && page.cards.isNotEmpty;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMoreServices() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    errorMessage = null;
    try {
      final CardsPage page = await _serviceRepository.getServices(key: nextKey);
      final existingIds = services.map((e) => e.id).toSet();
      final newItems = page.cards.where((c) => !existingIds.contains(c.id)).toList();
      services.addAll(newItems);
      nextKey = page.nextKey;
      hasMore = page.nextKey != null && page.cards.isNotEmpty;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
    }
  }

  @action
  Future<void> createService(ServiceEntity service) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _serviceRepository.createService(service);
      await loadServices();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateService(ServiceEntity service) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _serviceRepository.updateService(service);
      await loadServices();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addReview(String serviceId, ReviewEntity review) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _serviceRepository.addReview(serviceId, review);
      await loadServices();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadServiceDetails(String id) async {
    isLoading = true;
    errorMessage = null;
    try {
      final service = await _serviceRepository.getService(id);
      final index = services.indexWhere((s) => s.id == id);
      if (index >= 0) {
        services[index] = service;
      } else {
        services.add(service);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void setCategory(ServiceCategory? category) {
    selectedCategory = category;
  }
}
