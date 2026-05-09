import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../store/settings_store.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../widgets/profile_banner.dart';
import '../widgets/statistics_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: AppLocalizations.of(context)!.settingsKorstPromo,
          subject: 'Korst',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = sl<SettingsStore>();
    final authStore = sl<AuthStore>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(title: const SizedBox.shrink()),
      body: RefreshIndicator(
        onRefresh: () async {
          await authStore.bootstrap();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: l10n.settingsTitle,
                subtitle: l10n.appSettings,
                icon: Icons.tune_outlined,
                trailing: IconButton.filled(
                  onPressed: () => context.push('/user-profile/me'),
                  icon: const Icon(Icons.person_outline),
                ),
              ),
              const ProfileBanner(),
              const SizedBox(height: 16),
              const StatisticsWidget(),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.myProfile,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 12),
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cases_rounded),
                      title: Text(l10n.profileServices),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/my-services'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(l10n.profileEdit),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/edit-profile'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.star_border),
                      title: Text(AppLocalizations.of(context)!.publicProfile),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/user-profile/me');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.comment_outlined),
                      title: Text(AppLocalizations.of(context)!.myReviews),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/my-reviews'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.appSettings,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 12),
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.themeTitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Observer(
                            builder: (_) => SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode, size: 18),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode, size: 18),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto, size: 18),
                                ),
                              ],
                              selected: {store.themeMode},
                              onSelectionChanged:
                                  (Set<ThemeMode> newSelection) {
                                    store.setThemeMode(newSelection.first);
                                  },
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.languageTitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Observer(
                            builder: (_) => DropdownButton<String>(
                              value: store.useSystemLocale
                                  ? 'system'
                                  : store.locale.languageCode,
                              underline: const SizedBox.shrink(),
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              items: [
                                const DropdownMenuItem(
                                  value: 'system',
                                  child: Text('Auto'),
                                ),
                                const DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'ru',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.russianLanguage,
                                  ),
                                ),
                                const DropdownMenuItem(
                                  value: 'es',
                                  child: Text('Español'),
                                ),
                                const DropdownMenuItem(
                                  value: 'de',
                                  child: Text('Deutsch'),
                                ),
                                const DropdownMenuItem(
                                  value: 'zh',
                                  child: Text('中文'),
                                ),
                              ],
                              onChanged: (String? newLocale) {
                                if (newLocale != null) {
                                  if (newLocale == 'system') {
                                    store.setSystemLocale();
                                  } else {
                                    store.setLocale(Locale(newLocale));
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.additional,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 12),
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.star_rate),
                      title: Text(AppLocalizations.of(context)!.rateApp),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _rateApp(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: Text(AppLocalizations.of(context)!.shareApp),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _shareApp(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: Text(l10n.privacyPolicy),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/privacy'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(l10n.termsOfUse),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/terms'),
                    ),
                    if (kDebugMode) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bug_report),
                        title: const Text('Logs (Talker)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/logs'),
                      ),
                    ],
                  ],
                ),
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
                label: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
