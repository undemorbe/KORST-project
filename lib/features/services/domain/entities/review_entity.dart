class ReviewEntity {
  final String uid;
  final String text;
  final double rating;
  final DateTime created;
  final DateTime updated;

  ReviewEntity({
    required this.uid,
    required this.text,
    required this.rating,
    required this.created,
    required this.updated,
  });

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      uid: json['uid'] as String,
      text: json['text'] as String,
      rating: (json['rating'] as num).toDouble(),
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'text': text,
      'rating': rating,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
