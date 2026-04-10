import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../store/settings_store.dart';
import '../../../auth/presentation/store/auth_store.dart';

class SettingsAllPage extends StatelessWidget {
  const SettingsAllPage({super.key});

  Future<void> _rateApp(BuildContext context) async {
    try {
      final inAppReview = InAppReview.instance;
      final available = await inAppReview.isAvailable();
      if (available) {
        await inAppReview.requestReview();
        return;
      }
      await inAppReview.openStoreListing();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть рейтинг: $e')),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Korst — сервисы рядом.\n\nОткрыть приложение: korst:/// \n',
          subject: 'Korst',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось поделиться: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = sl<SettingsStore>();
    final authStore = sl<AuthStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    label: Text('System'),
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
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.push('/logs'),
                child: const Text('Логи (Talker)'),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'Полезное',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _rateApp(context),
                  icon: const Icon(Icons.star_rate),
                  label: const Text('Rate app'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _shareApp(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share app'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/privacy'),
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Confidential'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/terms'),
                  icon: const Icon(Icons.description),
                  label: const Text('Условия'),
                ),
              ],
            ),
            const SizedBox(height: 32),
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
