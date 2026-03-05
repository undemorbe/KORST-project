import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:korst/core/theme/app_theme.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    title: 'Test App',
    theme: AppTheme.lightTheme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
    ],
    home: child,
  );
}
