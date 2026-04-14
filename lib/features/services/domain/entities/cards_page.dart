import 'service_entity.dart';

class CardsPage {
  final List<ServiceEntity> cards;
  final String? nextKey;

  CardsPage({required this.cards, required this.nextKey});

  factory CardsPage.fromJson(Map<String, dynamic> json) {
    return CardsPage(
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => ServiceEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextKey: json['nextKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((e) => e.toJson()).toList(),
      'nextKey': nextKey,
    };
  }
}
