import 'package:mobx/mobx.dart';
import '../../../../core/storage/local_storage.dart';

part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  final LocalStorageService _storage;

  _HomeStore(this._storage) {
    _loadCount();
  }

  @observable
  int count = 0;

  @action
  void increment() {
    count++;
    _saveCount();
  }

  @action
  void decrement() {
    count--;
    _saveCount();
  }

  void _loadCount() {
    count = _storage.get('counter_value', defaultValue: 0);
  }

  void _saveCount() {
    _storage.put('counter_value', count);
  }
}
