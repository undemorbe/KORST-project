import '../entities/cards_page.dart';
import '../repositories/service_repository.dart';

class GetServices {
  final ServiceRepository repository;

  GetServices(this.repository);

  Future<CardsPage> call({required String? key}) async {
    return await repository.getServices(key: key);
  }
}
