import 'package:mobx/mobx.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/usecases/get_services.dart';

part 'service_store.g.dart';

// ignore: library_private_types_in_public_api
class ServiceStore = _ServiceStore with _$ServiceStore;

abstract class _ServiceStore with Store {
  final GetServices _getServices;

  _ServiceStore(this._getServices);

  @observable
  ObservableList<ServiceEntity> services = ObservableList<ServiceEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @observable
  ServiceCategory? selectedCategory;

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
      final result = await _getServices();
      services = ObservableList.of(result);
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
