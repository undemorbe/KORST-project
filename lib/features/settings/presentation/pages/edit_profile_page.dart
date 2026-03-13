import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/store/auth_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _telegramController;
  
  // Dynamic contacts
  final Map<String, TextEditingController> _otherContactsControllers = {};

  @override
  void initState() {
    super.initState();
    final profile = _authStore.userProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    
    final contacts = profile?.contacts ?? {};
    _emailController = TextEditingController(text: contacts['email'] ?? '');
    _telegramController = TextEditingController(text: contacts['telegram'] ?? '');
    
    if (contacts['other'] is Map) {
      (contacts['other'] as Map).forEach((key, value) {
        _otherContactsControllers[key.toString()] = TextEditingController(text: value.toString());
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telegramController.dispose();
    for (var controller in _otherContactsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addContactField() {
    String key = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить контакт'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Тип (например, Instagram)'),
            onChanged: (value) => key = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (key.isNotEmpty) {
                  setState(() {
                    _otherContactsControllers[key] = TextEditingController();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final currentProfile = _authStore.userProfile;
      if (currentProfile == null) return;

      final Map<String, dynamic> otherContacts = {};
      _otherContactsControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          otherContacts[key] = controller.text;
        }
      });

      final updatedUser = UserEntity(
        uid: currentProfile.uid,
        name: _nameController.text,
        phone: currentProfile.phone,
        photoUrl: currentProfile.photoUrl,
        contacts: {
          'email': _emailController.text,
          'telegram': _telegramController.text,
          'other': otherContacts,
        },
        createdCards: currentProfile.createdCards,
        bookings: currentProfile.bookings,
        created: currentProfile.created,
        updated: DateTime.now(),
      );

      await _authStore.updateProfile(updatedUser);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          Observer(
            builder: (_) => _authStore.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _save,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (v) => v?.isEmpty == true ? 'Введите имя' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telegramController,
                decoration: const InputDecoration(labelText: 'Telegram'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Другие контакты', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addContactField),
                ],
              ),
              ..._otherContactsControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(labelText: entry.key),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _otherContactsControllers.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
