import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class GetServices {
  final ServiceRepository repository;

  GetServices(this.repository);

  Future<List<ServiceEntity>> call() async {
    return await repository.getServices();
  }
}
