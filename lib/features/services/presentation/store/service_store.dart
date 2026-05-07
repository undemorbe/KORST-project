import 'package:mobx/mobx.dart';
import '../../domain/entities/cards_page.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/service_repository.dart';

part 'service_store.g.dart';

enum SortOption { newest, priceAsc, priceDesc, rating }

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

  @observable
  double? minPrice;

  @observable
  double? maxPrice;

  @observable
  double? minRating;

  @observable
  SortOption sortBy = SortOption.newest;

  @computed
  List<ServiceEntity> get filteredServices {
    var result = services.where((service) {
      final normalizedQuery = searchQuery.toLowerCase();
      final matchesSearch =
          service.title.toLowerCase().contains(normalizedQuery) ||
          service.description.toLowerCase().contains(normalizedQuery) ||
          service.tags.any(
            (tag) => tag.toLowerCase().contains(normalizedQuery),
          );
      final matchesCategory =
          selectedCategory == null || service.category == selectedCategory;
      final matchesMinPrice = minPrice == null || service.price >= minPrice!;
      final matchesMaxPrice = maxPrice == null || service.price <= maxPrice!;
      final matchesMinRating =
          minRating == null || service.rating >= minRating!;
      return matchesSearch &&
          matchesCategory &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesMinRating;
    }).toList();

    switch (sortBy) {
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.newest:
        result.sort((a, b) => b.created.compareTo(a.created));
        break;
    }
    return result;
  }

  @action
  Future<void> loadServices() async {
    if (isLoading) return; // Prevent multiple simultaneous requests
    isLoading = true;
    errorMessage = null;
    try {
      final query = searchQuery.trim();
      final CardsPage page = query.isEmpty
          ? await _serviceRepository.getServices(key: null)
          : await _serviceRepository.searchServices(query: query, key: null);
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
      final query = searchQuery.trim();
      final CardsPage page = query.isEmpty
          ? await _serviceRepository.getServices(key: nextKey)
          : await _serviceRepository.searchServices(query: query, key: nextKey);
      final existingIds = services.map((e) => e.id).toSet();
      final newItems = page.cards
          .where((c) => !existingIds.contains(c.id))
          .toList();
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
  Future<String?> createService(ServiceEntity service) async {
    isLoading = true;
    errorMessage = null;
    try {
      final cardId = await _serviceRepository.createService(service);
      isLoading = false;
      await loadServices();
      if (cardId != null) return cardId;

      // Try to find the newly created service if the backend didn't return an ID
      final matchingServices = services
          .where((s) => s.title == service.title && s.price == service.price)
          .toList();

      if (matchingServices.isNotEmpty) {
        // Assume the latest created is the first or last depending on sort, but let's take the first one
        return matchingServices.first.id;
      }
      return null;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> uploadCardImage(String cardId, String filePath) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _serviceRepository.uploadCardImage(cardId, filePath);
      isLoading = false;
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
      isLoading = false;
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
      isLoading = false;
      await loadServices();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> createReply(String cardId) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _serviceRepository.createReply(cardId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> approveExecutor({
    required String cardId,
    required String executorId,
  }) async {
    errorMessage = null;
    try {
      await _serviceRepository.approveExecutor(
        cardId: cardId,
        executorId: executorId,
      );
      await loadServiceDetails(cardId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  @action
  Future<void> rejectExecutor({
    required String cardId,
    required String executorId,
  }) async {
    errorMessage = null;
    try {
      await _serviceRepository.rejectExecutor(
        cardId: cardId,
        executorId: executorId,
      );
      await loadServiceDetails(cardId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  @action
  Future<void> closeCard({
    required String cardId,
    required String status,
  }) async {
    errorMessage = null;
    try {
      await _serviceRepository.closeCard(cardId: cardId, status: status);
      await loadServiceDetails(cardId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  @action
  Future<void> loadServiceDetails(String id) async {
    if (isLoading) return; // Prevent multiple simultaneous requests
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
    loadServices();
  }

  @action
  void setCategory(ServiceCategory? category) {
    selectedCategory = category;
  }

  @action
  void setFilters({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    SortOption? sortBy,
  }) {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.minRating = minRating;
    if (sortBy != null) this.sortBy = sortBy;
  }
}
