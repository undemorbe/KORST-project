class ExecutorEntity {
  final String id;
  final String name;
  final String? surname;
  final String? imageUrl;
  final double rating;

  ExecutorEntity({
    required this.id,
    required this.name,
    this.surname,
    this.imageUrl,
    required this.rating,
  });

  String get displayName =>
      surname != null && surname!.isNotEmpty ? '$name $surname' : name;

  factory ExecutorEntity.fromJson(Map<String, dynamic> json) {
    return ExecutorEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      imageUrl: json['image-url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
