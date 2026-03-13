import '../entities/service_entity.dart';
import '../entities/review_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices();
  Future<ServiceEntity> getService(String id);
  Future<void> createService(ServiceEntity service);
  Future<void> addReview(String serviceId, ReviewEntity review);
}
