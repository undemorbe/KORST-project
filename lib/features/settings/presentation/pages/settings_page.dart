import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../store/settings_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = sl<SettingsStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Switcher
            Text(
              l10n.themeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Observer(
              builder: (_) => SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.lightTheme),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.darkTheme),
                    icon: const Icon(Icons.dark_mode),
                  ),
                  const ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'), // Or l10n key
                    icon: Icon(Icons.brightness_auto),
                  ),
                ],
                selected: {store.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  store.setThemeMode(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Language Switcher
            Text(
              l10n.languageTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Observer(
              builder: (_) => DropdownButton<Locale>(
                value: store.locale,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('ru'),
                    child: Text('Русский'),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    store.setLocale(newLocale);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
