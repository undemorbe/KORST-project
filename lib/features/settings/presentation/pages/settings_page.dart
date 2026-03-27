import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../store/settings_store.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../widgets/profile_banner.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = sl<SettingsStore>();
    final authStore = sl<AuthStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProfileBanner(),
            const SizedBox(height: 16),
            
            OutlinedButton(
              onPressed: () {
                context.push('/edit-profile');
              },
              child: const Text('Редактировать профиль'),
            ),

            if (kDebugMode) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  context.push('/logs');
                },
                child: const Text('Логи (Talker)'),
              ),
            ],
            
            const SizedBox(height: 24),
            
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
            
            const SizedBox(height: 48),
            
            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                await authStore.logout();
                if (context.mounted) {
                  context.go('/onboarding');
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Выйти из аккаунта',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
