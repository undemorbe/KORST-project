class ReviewAuthorEntity {
  final String name;
  final String? surname;
  final double rating;

  ReviewAuthorEntity({
    required this.name,
    this.surname,
    required this.rating,
  });
}

class UserReviewEntity {
  final double rating;
  final String comment;
  final ReviewAuthorEntity author;

  UserReviewEntity({
    required this.rating,
    required this.comment,
    required this.author,
  });
}
