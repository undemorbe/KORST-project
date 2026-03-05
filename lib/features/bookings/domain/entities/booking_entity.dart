class BookingEntity {
  final String id;
  final String serviceId;
  final String serviceTitle;
  final double price;
  final DateTime date;

  BookingEntity({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'price': price,
        'date': date.toIso8601String(),
      };

  factory BookingEntity.fromJson(Map<String, dynamic> json) => BookingEntity(
        id: json['id'],
        serviceId: json['serviceId'],
        serviceTitle: json['serviceTitle'],
        price: json['price'],
        date: DateTime.parse(json['date']),
      );
}
