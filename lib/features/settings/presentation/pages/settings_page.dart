import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/profile_banner.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                context.push('/profile');
              },
              child: const Text('Открыть профиль'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push('/my-services');
              },
              child: const Text('Мои карточки'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push('/settings-all');
              },
              child: const Text('Настройки'),
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
          ],
        ),
      ),
    );
  }
}
