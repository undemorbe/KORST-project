import 'package:get_it/get_it.dart';
import '../../core/storage/local_storage.dart';
import '../../features/home/presentation/store/home_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final storageService = LocalStorageServiceImpl();
  await storageService.init();
  sl.registerSingleton<LocalStorageService>(storageService);

  // Features - Home
  sl.registerFactory(() => HomeStore(sl()));
}
