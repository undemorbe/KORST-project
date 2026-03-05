import 'service_category.dart';

class ServiceEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final ServiceCategory category;

  ServiceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}
