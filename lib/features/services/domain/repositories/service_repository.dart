import '../entities/service_entity.dart';
import '../entities/review_entity.dart';
import '../entities/cards_page.dart';

abstract class ServiceRepository {
  Future<CardsPage> getServices({required String? key});
  Future<ServiceEntity> getService(String id);
  Future<String?> createService(ServiceEntity service);
  Future<void> updateService(ServiceEntity service);
  Future<void> addReview(String serviceId, ReviewEntity review);
  Future<String> uploadCardImage(String cardId, String filePath);
}
