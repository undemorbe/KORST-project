import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:talker/talker.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/settings/presentation/store/settings_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await di.init();

  final talker = di.sl<Talker>();
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return false;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsStore = di.sl<SettingsStore>();

    return Observer(
      builder: (_) {
        return MaterialApp.router(
          title: 'K O R S T',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsStore.themeMode,
          locale: settingsStore.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
