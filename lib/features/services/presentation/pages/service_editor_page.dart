import 'package:korst/core/widgets/glass.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_entity.dart';
import '../store/service_store.dart';
import '../../../auth/presentation/store/auth_store.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class ServiceEditorPage extends StatefulWidget {
  final ServiceEntity? initialService;

  const ServiceEditorPage({super.key, this.initialService});

  bool get isEditing => initialService != null;

  @override
  State<ServiceEditorPage> createState() => _ServiceEditorPageState();
}

class _ServiceEditorPageState extends State<ServiceEditorPage> {
  final ServiceStore _serviceStore = GetIt.I<ServiceStore>();
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _tagsController;
  late ServiceCategory _selectedCategory;
  String? _pickedImagePath;
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    final service = widget.initialService;
    _titleController = TextEditingController(text: service?.title ?? '');
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: service != null ? service.price.toStringAsFixed(0) : '',
    );
    _tagsController = TextEditingController(
      text: service?.tags.join(', ') ?? '',
    );
    _selectedCategory = service?.category ?? ServiceCategory.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 60,
    );
    if (file != null) {
      setState(() {
        _pickedImagePath = file.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _authStore.userProfile;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorUserNotFound)),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final base = widget.initialService;
    final now = DateTime.now();
    final service = ServiceEntity(
      uid: base?.uid ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      currency: base?.currency ?? _selectedCurrency,
      type: base?.type ?? AppLocalizations.of(context)!.task,
      author: base?.author ?? user,
      timesBooked: base?.timesBooked ?? 0,
      rating: base?.rating ?? 0,
      reviews: base?.reviews ?? const [],
      tags: tags,
      created: base?.created ?? now,
      updated: now,
      category: _selectedCategory,
      imageUrl: base?.imageUrl ?? 'https://placehold.co/600x400',
    );

    if (widget.isEditing) {
      await _serviceStore.updateService(service);
      if (_pickedImagePath != null && _serviceStore.errorMessage == null) {
        await _serviceStore.uploadCardImage(service.id, _pickedImagePath!);
      }
    } else {
      final cardId = await _serviceStore.createService(service);
      if (cardId != null &&
          _pickedImagePath != null &&
          _serviceStore.errorMessage == null) {
        await _serviceStore.uploadCardImage(cardId, _pickedImagePath!);
      }
    }

    if (!mounted) return;
    if (_serviceStore.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_serviceStore.errorMessage!)));
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? AppLocalizations.of(context)!.editTask
        : AppLocalizations.of(context)!.newTask;
    final buttonText = widget.isEditing
        ? AppLocalizations.of(context)!.updateTask
        : AppLocalizations.of(context)!.createTask;

    return Scaffold(extendBodyBehindAppBar: true, extendBody: true,
      appBar: GlassAppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: _pickedImagePath != null
                        ? Image.file(File(_pickedImagePath!), fit: BoxFit.cover)
                        : (widget.initialService?.imageUrl != null &&
                              widget.initialService!.imageUrl.isNotEmpty &&
                              !widget.initialService!.imageUrl.contains(
                                'placehold.co',
                              ))
                        ? CachedNetworkImage(
                            imageUrl: widget.initialService!.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.addPhoto,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.taskDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.title,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? AppLocalizations.of(context)!.enterTitle
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.description,
                        ),
                        maxLines: 3,
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
                        controller: _priceController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.budget),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppLocalizations.of(context)!.enterBudget;
                          }
                          final parsed = double.tryParse(
                            v.replaceAll(',', '.'),
                          );
                          if (parsed == null) return AppLocalizations.of(context)!.invalidBudget;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ServiceCategory>(
                        initialValue: _selectedCategory,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.category,
                        ),
                        items: ServiceCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCategory = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.currency,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          DropdownMenuItem(value: 'KZT', child: Text('KZT')),
                          DropdownMenuItem(value: 'RUB', child: Text('RUB')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCurrency = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.tags,
                          hintText: AppLocalizations.of(context)!.tagsHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: _serviceStore.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _serviceStore.isLoading
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
    );
  }
}
