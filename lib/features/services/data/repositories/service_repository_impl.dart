import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final List<ServiceEntity> _services = [
    ServiceEntity(
      uid: '1',
      title: 'Cleaning Service',
      description: 'Professional home cleaning service. We ensure every corner of your house is spotless.',
      price: 50.0,
      currency: 'USD',
      type: 'service',
      timesBooked: 120,
      rating: 4.8,
      reviews: [
        ReviewEntity(
          uid: 'r1',
          text: 'Great service!',
          rating: 5.0,
          created: DateTime.now().subtract(const Duration(days: 2)),
          updated: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      tags: ['cleaning', 'home', 'fast'],
      created: DateTime.now(),
      updated: DateTime.now(),
      category: ServiceCategory.cleaning,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ServiceEntity(
      uid: '2',
      title: 'Plumbing',
      description: 'Expert plumbing solutions for all your needs. Leak repairs, pipe installation, and more.',
      price: 80.0,
      currency: 'USD',
      type: 'service',
      timesBooked: 45,
      rating: 4.5,
      reviews: [],
      tags: ['plumbing', 'repair'],
      created: DateTime.now(),
      updated: DateTime.now(),
      category: ServiceCategory.repair,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ServiceEntity(
      uid: '3',
      title: 'Electrician',
      description: 'Certified electricians available for wiring, repairs, and electrical maintenance.',
      price: 75.0,
      currency: 'USD',
      type: 'service',
      timesBooked: 89,
      rating: 4.9,
      reviews: [],
      tags: ['electric', 'repair', 'safety'],
      created: DateTime.now(),
      updated: DateTime.now(),
      category: ServiceCategory.repair,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ServiceEntity(
      uid: '4',
      title: 'Gardening',
      description: 'Landscape design and maintenance. Keep your garden green and beautiful all year round.',
      price: 45.0,
      currency: 'USD',
      type: 'service',
      timesBooked: 30,
      rating: 4.7,
      reviews: [],
      tags: ['garden', 'outdoor', 'nature'],
      created: DateTime.now(),
      updated: DateTime.now(),
      category: ServiceCategory.other,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ServiceEntity(
      uid: '5',
      title: 'Car Wash',
      description: 'Premium car wash service at your doorstep. Interior and exterior cleaning.',
      price: 30.0,
      currency: 'USD',
      type: 'service',
      timesBooked: 200,
      rating: 4.6,
      reviews: [],
      tags: ['car', 'cleaning', 'mobile'],
      created: DateTime.now(),
      updated: DateTime.now(),
      category: ServiceCategory.cleaning,
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  @override
  Future<List<ServiceEntity>> getServices() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_services); // Return copy
  }

  @override
  Future<ServiceEntity> getService(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _services.firstWhere((e) => e.uid == id);
    } catch (e) {
      throw Exception('Service not found');
    }
  }

  @override
  Future<void> createService(ServiceEntity service) async {
    await Future.delayed(const Duration(seconds: 1));
    _services.add(service);
  }

  @override
  Future<void> addReview(String serviceId, ReviewEntity review) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _services.indexWhere((e) => e.uid == serviceId);
    if (index != -1) {
      final service = _services[index];
      final updatedReviews = List<ReviewEntity>.from(service.reviews)..add(review);
      
      // Recalculate rating
      final totalRating = updatedReviews.fold(0.0, (sum, r) => sum + r.rating);
      final newRating = totalRating / updatedReviews.length;

      final updatedService = ServiceEntity(
        uid: service.uid,
        title: service.title,
        description: service.description,
        price: service.price,
        currency: service.currency,
        type: service.type,
        author: service.author,
        timesBooked: service.timesBooked,
        rating: newRating,
        reviews: updatedReviews,
        tags: service.tags,
        created: service.created,
        updated: DateTime.now(),
        category: service.category,
        imageUrl: service.imageUrl,
      );
      
      _services[index] = updatedService;
    } else {
      throw Exception('Service not found');
    }
  }
}
