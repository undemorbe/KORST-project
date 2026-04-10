import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../../users/presentation/pages/user_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthStore>().userProfile;
    final userId = user?.uid ?? '';
    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Не удалось определить ваш профиль'),
          ),
        ),
      );
    }
    return UserProfilePage(
      userId: userId,
      isOwnProfileHint: true,
    );
  }
}
