import 'dart:async';
import 'package:workmanager/workmanager.dart';
import '../../features/notifications/notification_service.dart';
import '../../core/config/env_config.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/messenger/domain/repositories/messenger_repository.dart';
import '../../core/storage/local_storage.dart';
import 'dart:convert';
import '../../features/messenger/domain/entities/chats_response.dart';

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
      _compareAndNotify(cachedResponse, response, notificationService);
    }

    // Save new cache
    await localStorage.put('cache_chats', jsonEncode(response.toJson()));
  } catch (e) {
    // Ignore errors in background
  }
}

void _compareAndNotify(
  ChatsResponse oldData,
  ChatsResponse newData,
  NotificationService notificationService,
) {
  final allNewChats = [...newData.customerChats, ...newData.merchantChats];
  final allOldChats = [...oldData.customerChats, ...oldData.merchantChats];

  for (var newChat in allNewChats) {
    if (newChat.lastMessage == null) continue;

    final oldChat = allOldChats.cast<dynamic>().firstWhere(
      (c) => c.id == newChat.id,
      orElse: () => null,
    );

    // If it's a new chat or the last message is different, and it's not from us
    if (oldChat == null || oldChat.lastMessage?.id != newChat.lastMessage?.id) {
      // Check if it's from us by comparing authorId with chat user id
      // Since 'me' isn't explicitly known without SessionStore, we assume if authorId == chat.user.id, it's from the other person
      if (newChat.lastMessage!.authorId == newChat.user.id) {
        notificationService.showNotification(
          id: newChat.id.hashCode,
          title: 'New message from ${newChat.user.name}',
          body: newChat.lastMessage!.text,
          payload: newChat.id,
        );
      }
    }
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
