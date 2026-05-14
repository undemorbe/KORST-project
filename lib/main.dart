import 'dart:async';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:talker/talker.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/animated_gradient_background.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'core/background/background_task_manager.dart';
import 'core/network/connectivity_service.dart';
import 'features/auth/presentation/store/auth_store.dart';
import 'features/auth/presentation/store/session_store.dart';
import 'features/messenger/presentation/store/messenger_store.dart';
import 'features/notifications/notification_service.dart';
import 'features/settings/presentation/store/settings_store.dart';
import 'core/widgets/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await di.init();
  di.sl<NotificationService>().setPayloadHandler(_openChatFromNotification);
  await di.sl<BackgroundTaskManager>().init();
  await di.sl<ConnectivityService>().init();
  di.sl<SessionStore>().start();

  final talker = di.sl<Talker>();
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return false;
  };

  _initDeepLinks(talker);

  runApp(const MyApp());
}

void _initDeepLinks(Talker talker) {
  final appLinks = AppLinks();

  // Handle link that launched the app from terminated state
  appLinks.getInitialLink().then((uri) {
    if (uri != null) _handleDeepLink(uri, talker);
  }).catchError((Object e) {
    talker.warning('Deep link initial error: $e');
    return null;
  });

  // Handle links while app is running
  appLinks.uriLinkStream.listen(
    (uri) => _handleDeepLink(uri, talker),
    onError: (e) => talker.warning('Deep link stream error: $e'),
  );
}

/// Routes:
///   korst://cards/{id}              → /service/{id}
///   https://host/links/service/{id} → /service/{id}
void _handleDeepLink(Uri uri, Talker talker) {
  talker.info('Deep link: $uri');

  String? cardId;

  if (uri.scheme == 'korst') {
    // korst://cards/{id}
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'cards') {
      cardId = segments[1];
    } else if (segments.length == 1 && uri.host == 'cards') {
      cardId = segments[0];
    }
  } else if (uri.scheme == 'https' || uri.scheme == 'http') {
    // https://host/links/service/{id}
    final segments = uri.pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'links' &&
        segments[1] == 'service') {
      cardId = segments[2];
    }
  }

  if (cardId != null && cardId.isNotEmpty) {
    // Defer navigation until after first frame (router may not be ready yet)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.push('/service/$cardId');
    });
  }
}

Future<void> _openChatFromNotification(String chatId) async {
  final store = di.sl<MessengerStore>();
  final found = await store.selectChatById(chatId);
  if (found) {
    AppRouter.router.push('/chat', extra: store);
  } else {
    AppRouter.router.go('/chats');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsStore = di.sl<SettingsStore>();
    final sessionStore = di.sl<SessionStore>();
    final authStore = di.sl<AuthStore>();
    final messengerStore = di.sl<MessengerStore>();
    final backgroundTaskManager = di.sl<BackgroundTaskManager>();

    return Observer(
      builder: (_) {
        final _ = sessionStore.eventsVersion;
        final isLoggedIn = authStore.isLoggedIn;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isLoggedIn) {
            messengerStore.startRealtime();
            messengerStore.setMyUserId(authStore.userProfile?.uid);
            backgroundTaskManager.startPolling();
          } else {
            unawaited(messengerStore.stopRealtime());
            backgroundTaskManager.stopPolling();
          }
        });
        if (sessionStore.sessionExpired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sessionStore.markHandled();
          });
        }
        return MaterialApp.router(
          title: 'K O R S T',
          
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsStore.themeMode,
          locale: settingsStore.useSystemLocale ? null : settingsStore.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return AnimatedGradientBackground(
              child: ConnectivityBanner(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
