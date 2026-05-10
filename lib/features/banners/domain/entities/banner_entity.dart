class BannerEntity {
  final String company;
  final String imageUrl;
  final String link;

  const BannerEntity({
    required this.company,
    required this.imageUrl,
    required this.link,
  });

  factory BannerEntity.fromJson(Map<String, dynamic> json) {
    return BannerEntity(
      company: (json['company'] as String?) ?? '',
      imageUrl:
          (json['image-url'] as String?) ??
          (json['imageUrl'] as String?) ??
          '',
      link: (json['link'] as String?) ?? '',
    );
  }
}
