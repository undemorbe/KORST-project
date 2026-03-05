import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  @override
  Future<List<ServiceEntity>> getServices() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      ServiceEntity(
        id: '1',
        title: 'Cleaning Service',
        description: 'Professional home cleaning service. We ensure every corner of your house is spotless.',
        price: 50.0,
        imageUrl: 'https://via.placeholder.com/150',
        category: ServiceCategory.cleaning,
      ),
      ServiceEntity(
        id: '2',
        title: 'Plumbing',
        description: 'Expert plumbing solutions for all your needs. Leak repairs, pipe installation, and more.',
        price: 80.0,
        imageUrl: 'https://via.placeholder.com/150',
        category: ServiceCategory.repair,
      ),
      ServiceEntity(
        id: '3',
        title: 'Electrician',
        description: 'Certified electricians available for wiring, repairs, and electrical maintenance.',
        price: 75.0,
        imageUrl: 'https://via.placeholder.com/150',
        category: ServiceCategory.repair,
      ),
      ServiceEntity(
        id: '4',
        title: 'Gardening',
        description: 'Landscape design and maintenance. Keep your garden green and beautiful all year round.',
        price: 45.0,
        imageUrl: 'https://via.placeholder.com/150',
        category: ServiceCategory.other,
      ),
      ServiceEntity(
        id: '5',
        title: 'Car Wash',
        description: 'Premium car wash service at your doorstep. Interior and exterior cleaning.',
        price: 30.0,
        imageUrl: 'https://via.placeholder.com/150',
        category: ServiceCategory.cleaning,
      ),
    ];
  }
}
