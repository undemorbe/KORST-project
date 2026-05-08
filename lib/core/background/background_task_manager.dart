import 'dart:async';
import 'dart:convert';

import 'package:workmanager/workmanager.dart';

import '../../core/config/env_config.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/storage/local_storage.dart';
import '../../features/messenger/domain/entities/chats_response.dart';
import '../../features/messenger/domain/repositories/messenger_repository.dart';
import '../../features/notifications/notification_service.dart';
import 'chats_notification_helper.dart';

const fetchChatsTask = "fetchChatsTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchChatsTask) {
      await _checkNewMessagesBackground();
    }
    return Future.value(true);
  });
}

Future<void> _checkNewMessagesBackground() async {
  // Ensure basic things are initialized in background
  try {
    await EnvConfig.load();
    await di.init();
  } catch (_) {
    // If already initialized
  }

  final notificationService = NotificationService();
  await notificationService.init();

  final messengerRepo = di.sl<MessengerRepository>();
  final localStorage = di.sl<LocalStorageService>();

  try {
    final response = await messengerRepo.getChats();
    final cachedStr = localStorage.get('cache_chats') as String?;

    if (cachedStr != null) {
      final cachedResponse = ChatsResponse.fromJson(jsonDecode(cachedStr));
      ChatsNotificationHelper.compareAndNotify(
        oldData: cachedResponse,
        newData: response,
        notificationService: notificationService,
      );
    }

    await localStorage.put('cache_chats', jsonEncode(response.toJson()));
  } catch (e) {
    // Ignore errors in background
  }
}


class BackgroundTaskManager {
  Timer? _foregroundTimer;
  bool _initialized = false;
  bool _pollingStarted = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(callbackDispatcher);
    } catch (_) {}

    await NotificationService().init();
    _initialized = true;
  }

  void startPolling() {
    if (_pollingStarted) return;
    _pollingStarted = true;
    try {
      unawaited(
        Workmanager().registerPeriodicTask(
          'fetch_chats_periodic',
          fetchChatsTask,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
        ),
      );
    } catch (_) {}

    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }

  void stopPolling() {
    if (!_pollingStarted) return;
    _pollingStarted = false;
    try {
      unawaited(Workmanager().cancelByUniqueName('fetch_chats_periodic'));
    } catch (_) {}
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }
}
