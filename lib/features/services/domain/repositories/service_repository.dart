import '../entities/service_entity.dart';
import '../entities/review_entity.dart';
import '../entities/cards_page.dart';
import '../entities/executor_entity.dart';

abstract class ServiceRepository {
  Future<CardsPage> getServices({required String? key});
  Future<CardsPage> searchServices({
    required String query,
    required String? key,
  });
  Future<ServiceEntity> getService(String id);
  Future<String?> createService(ServiceEntity service);
  Future<void> updateService(ServiceEntity service);
  Future<void> addReview(String serviceId, ReviewEntity review);
  Future<String> uploadCardImage(String cardId, String filePath);
  Future<void> createReply(String cardId);
  Future<void> approveExecutor({
    required String cardId,
    required String executorId,
  });
  Future<void> rejectExecutor({
    required String cardId,
    required String executorId,
  });
  Future<void> closeCard({required String cardId, required String status});
  Future<List<ExecutorEntity>> getExecutors(String cardId);
}
