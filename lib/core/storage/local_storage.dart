import 'package:hive_flutter/hive_flutter.dart';

abstract class LocalStorageService {
  Future<void> init();
  dynamic get(String key, {dynamic defaultValue});
  Future<void> put(String key, dynamic value);
  Future<void> delete(String key);
  Future<void> clear();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _boxName = 'app_preferences';
  late Box _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override
  dynamic get(String key, {dynamic defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
