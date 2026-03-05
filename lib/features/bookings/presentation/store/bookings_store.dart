import 'package:mobx/mobx.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/booking_entity.dart';

part 'bookings_store.g.dart';

class BookingsStore = _BookingsStore with _$BookingsStore;

abstract class _BookingsStore with Store {
  final LocalStorageService _storageService;
  static const String _bookingsKey = 'bookings';

  _BookingsStore(this._storageService) {
    _loadBookings();
  }

  @observable
  ObservableList<BookingEntity> bookings = ObservableList<BookingEntity>();

  @action
  void _loadBookings() {
    final List<dynamic>? stored = _storageService.get(_bookingsKey);
    if (stored != null) {
      bookings = ObservableList.of(stored.map((e) => BookingEntity.fromJson(Map<String, dynamic>.from(e))));
    }
  }

  @action
  Future<void> addBooking(BookingEntity booking) async {
    bookings.add(booking);
    await _storageService.put(_bookingsKey, bookings.map((e) => e.toJson()).toList());
  }
}
