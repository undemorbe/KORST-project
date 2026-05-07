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
          backgroundColor: colors.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? CachedNetworkImageProvider(photoUrl)
              : null,
          child: photoUrl == null || photoUrl.isEmpty
              ? Icon(Icons.person, size: 36, color: colors.onSurfaceVariant)
              : null,
        );

        return GlassCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: avatar,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, color: colors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  displayName.isNotEmpty
                      ? displayName
                      : AppLocalizations.of(context)!.user,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
