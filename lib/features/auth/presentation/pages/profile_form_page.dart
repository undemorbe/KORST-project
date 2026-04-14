import 'dart:io';
import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_profile_repository.dart';
import '../store/auth_store.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class ProfileFormPage extends StatefulWidget {
  final bool isEditing;

  const ProfileFormPage({super.key, required this.isEditing});

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
  String? _pickedImagePath;
  bool _isUploadingImage = false;

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
    _descriptionController = TextEditingController(
      text: profile?.description ?? '',
    );
    _emailController = TextEditingController(
      text: contacts['email']?.toString() ?? '',
    );
    _telegramController = TextEditingController(
      text: contacts['telegram']?.toString() ?? '',
    );
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
    if (_isUploadingImage) return;

    final phone = _authStore.phoneNumber ?? _authStore.userProfile?.phone ?? '';
    final base = _authStore.userProfile ?? UserEntity.empty(phone: phone);
    
    final updated = base.copyWith(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim().isEmpty
          ? null
          : _surnameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      contacts: {
        'email': _emailController.text.trim(),
        'telegram': _telegramController.text.trim(),
        'others': {
          if (_contactsController.text.trim().isNotEmpty)
            'other': _contactsController.text.trim(),
        },
      },
      updated: DateTime.now(),
    );

    // Сначала создаем/обновляем текстовый профиль, чтобы пользователь появился в БД
    await _authStore.updateProfile(updated);

    if (!mounted) return;

    if (_authStore.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authStore.errorMessage!)));
      return;
    }

    // Если есть фото - грузим его только после того как профиль создан
    if (_pickedImagePath != null) {
      try {
        final uploadedPhotoUrl = await _uploadProfileImage();
        if (uploadedPhotoUrl != null && mounted) {
           // Опционально можно еще раз дернуть updateProfile чтобы сохранить урл, 
           // но обычно бэкенд сам привязывает загруженное фото к юзеру. 
           // На всякий случай обновим локальный стейт
           final withPhoto = (_authStore.userProfile ?? updated).copyWith(
             photoUrl: uploadedPhotoUrl,
             updated: DateTime.now(),
           );
           await _authStore.updateProfile(withPhoto);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.profileCreatedButPhotoFailed}$e")),
        );
      }
    }

    if (!mounted) return;

    if (widget.isEditing) {
      context.pop();
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? AppLocalizations.of(context)!.editProfile
        : AppLocalizations.of(context)!.createProfile;
    final buttonText = widget.isEditing
        ? AppLocalizations.of(context)!.saveChanges
        : AppLocalizations.of(context)!.createProfileBtn;
    final profile = _authStore.userProfile;
    final photoUrl = profile?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(title),
        automaticallyImplyLeading: widget.isEditing,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _authStore.bootstrap();
            final profile = _authStore.userProfile;
            final contacts = profile?.contacts ?? {};
            final others = contacts['others'];
            String otherContact = '';
            if (others is Map && others['other'] is String) {
              otherContact = others['other'] as String;
            } else if (contacts['other'] is String) {
              otherContact = contacts['other'] as String;
            }
            if (mounted) {
              setState(() {
                _nameController.text = profile?.name ?? '';
                _surnameController.text = profile?.surname ?? '';
                _descriptionController.text = profile?.description ?? '';
                _emailController.text = contacts['email']?.toString() ?? '';
                _telegramController.text = contacts['telegram']?.toString() ?? '';
                _contactsController.text = otherContact;
              });
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _pickedImagePath != null
                                    ? FileImage(File(_pickedImagePath!))
                                    : hasPhoto
                                        ? CachedNetworkImageProvider(photoUrl)
                                    : null,
                                child: _pickedImagePath == null
                                        ? (hasPhoto
                                              ? null
                                              : Icon(
                                                  Icons.person,
                                                  size: 36,
                                                  color: Colors.grey.shade700,
                                                ))
                                    : null,
                              ),
                              if (_isUploadingImage)
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.basicData,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.firstName),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? AppLocalizations.of(context)!.enterFirstName
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.lastName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.aboutMe,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
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
                          decoration: const InputDecoration(
                            labelText: 'Telegram',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contactsController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.additionalContact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: (_authStore.isLoading || _isUploadingImage) ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: (_authStore.isLoading || _isUploadingImage)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_pickedImagePath == null) return null;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final url = await sl<UserProfileRepository>().uploadProfileImage(
        _pickedImagePath!,
      );
      return url;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }
}
