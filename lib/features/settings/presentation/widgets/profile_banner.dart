import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../../users/domain/repositories/user_profile_repository.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class ProfileBanner extends StatefulWidget {
  const ProfileBanner({super.key});

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final UserProfileRepository _repository = sl<UserProfileRepository>();
  Future<void> _loadProfile() async {
    try {
      final remoteProfile = await _repository.getOwnProfile();
      if (!mounted) return;
      
      final current = _authStore.userProfile;
      if (current == null) return;

      final updated = current.copyWith(
        name: remoteProfile.name,
        surname: remoteProfile.surname,
        phone: remoteProfile.phone,
        photoUrl: remoteProfile.photoUrl,
        description: remoteProfile.description,
        contacts: remoteProfile.contacts,
      );

      if (updated.name != current.name ||
          updated.surname != current.surname ||
          updated.phone != current.phone ||
          updated.photoUrl != current.photoUrl ||
          updated.description != current.description) {
        _authStore.updateLocalProfile(updated);
      }
    } catch (_) {
      // Ignore errors silently
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Observer(
      builder: (_) {
        if (!_authStore.isLoggedIn) {
          return const SizedBox.shrink();
        }

        final profile = _authStore.userProfile;
        if (profile == null) return const SizedBox.shrink();

        final displayName = [
          profile.name.trim(),
          (profile.surname ?? '').trim(),
        ].where((e) => e.isNotEmpty).join(' ');
        final phone = profile.phone;
        final photoUrl = profile.photoUrl;

        Widget avatar = CircleAvatar(
          radius: 36,
          backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? CachedNetworkImageProvider(photoUrl)
              : null,
          child: photoUrl == null || photoUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: 36,
                  color: colors.onSurfaceVariant,
                )
              : null,
        );

        return GlassCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: avatar,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : AppLocalizations.of(context)!.user,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                      ),
                      if (phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            phone,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
