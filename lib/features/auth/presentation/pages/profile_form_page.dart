import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_entity.dart';
import '../store/auth_store.dart';

class ProfileFormPage extends StatefulWidget {
  final bool isEditing;

  const ProfileFormPage({
    super.key,
    required this.isEditing,
  });

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  late TextEditingController _telegramController;
  late TextEditingController _contactsController;

  @override
  void initState() {
    super.initState();
    final profile = _authStore.userProfile;
    final contacts = profile?.contacts ?? {};
    final others = contacts['others'];
    String otherContact = '';
    if (others is Map && others['other'] is String) {
      otherContact = others['other'] as String;
    } else if (contacts['other'] is String) {
      otherContact = contacts['other'] as String;
    }

    _nameController = TextEditingController(text: profile?.name ?? '');
    _surnameController = TextEditingController(text: profile?.surname ?? '');
    _descriptionController = TextEditingController(text: profile?.description ?? '');
    _emailController = TextEditingController(text: contacts['email']?.toString() ?? '');
    _telegramController = TextEditingController(text: contacts['telegram']?.toString() ?? '');
    _contactsController = TextEditingController(text: otherContact);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _telegramController.dispose();
    _contactsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _authStore.phoneNumber ?? _authStore.userProfile?.phone ?? '';
    final base = _authStore.userProfile ?? UserEntity.empty(phone: phone);
    final updated = base.copyWith(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim().isEmpty ? null : _surnameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      contacts: {
        'email': _emailController.text.trim(),
        'telegram': _telegramController.text.trim(),
        'others': {
          if (_contactsController.text.trim().isNotEmpty) 'other': _contactsController.text.trim(),
        },
      },
      updated: DateTime.now(),
    );

    await _authStore.updateProfile(updated);
    if (!mounted) return;

    if (_authStore.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authStore.errorMessage!)),
      );
      return;
    }

    if (widget.isEditing) {
      context.pop();
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Редактирование профиля' : 'Создание профиля';
    final buttonText = widget.isEditing ? 'Сохранить изменения' : 'Создать профиль';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: widget.isEditing,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(Icons.person, size: 36, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Основные данные',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Имя'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Введите имя' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameController,
                          decoration: const InputDecoration(labelText: 'Фамилия'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'О себе'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telegramController,
                          decoration: const InputDecoration(labelText: 'Telegram'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contactsController,
                          decoration: const InputDecoration(labelText: 'Дополнительный контакт'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: _authStore.isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _authStore.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
