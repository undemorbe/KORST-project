import 'package:flutter_test/flutter_test.dart';
import 'package:korst/core/storage/local_storage.dart';
import 'package:korst/features/bookings/domain/entities/booking_entity.dart';
import 'package:korst/features/bookings/presentation/store/bookings_store.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;
  late BookingsStore store;

  setUp(() {
    mockStorage = MockLocalStorageService();
    when(() => mockStorage.get(any())).thenReturn(null);
    store = BookingsStore(mockStorage);
  });

  group('BookingsStore', () {
    test('initial state is correct', () {
      expect(store.bookings, isEmpty);
    });

    test('addBooking adds and saves', () async {
      when(() => mockStorage.put(any(), any())).thenAnswer((_) async {});

      final booking = BookingEntity(
        id: '1',
        serviceId: 's1',
        serviceTitle: 'Test Service',
        price: 100,
        date: DateTime.now(),
      );

      await store.addBooking(booking);

      expect(store.bookings.length, 1);
      expect(store.bookings.first.id, '1');
      verify(() => mockStorage.put('bookings', any())).called(1);
    });
  });
}
