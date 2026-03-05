import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:korst/features/services/domain/entities/service_category.dart';
import 'package:korst/features/services/domain/entities/service_entity.dart';
import 'package:korst/features/services/presentation/widgets/service_card.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  testGoldens('ServiceCard golden test', (tester) async {
    final service = ServiceEntity(
      id: '1',
      title: 'Golden Service',
      description: 'Description',
      price: 99.99,
      imageUrl: '', // Empty to trigger placeholder/error
      category: ServiceCategory.cleaning,
    );

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario(
        'Default',
        createTestWidget(
          ServiceCard(
            service: service,
            isFavorite: false,
            onFavoriteToggle: () {},
            onTap: () {},
          ),
        ),
      )
      ..addScenario(
        'Favorite',
        createTestWidget(
          ServiceCard(
            service: service,
            isFavorite: true,
            onFavoriteToggle: () {},
            onTap: () {},
          ),
        ),
      );

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'service_card_golden');
  });
}
