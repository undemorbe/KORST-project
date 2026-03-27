import '../entities/service_entity.dart';
import '../entities/review_entity.dart';
import '../entities/cards_page.dart';

abstract class ServiceRepository {
  Future<CardsPage> getServices({required String? key});
  Future<ServiceEntity> getService(String id);
  Future<void> createService(ServiceEntity service);
  Future<void> addReview(String serviceId, ReviewEntity review);
}
