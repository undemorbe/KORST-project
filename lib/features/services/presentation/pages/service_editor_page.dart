import 'package:korst/core/widgets/glass.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_entity.dart';
import '../store/service_store.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../../../core/widgets/app_layout.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class ServiceEditorPage extends StatefulWidget {
  final ServiceEntity? initialService;

  const ServiceEditorPage({super.key, this.initialService});

  bool get isEditing => initialService != null;

  @override
  State<ServiceEditorPage> createState() => _ServiceEditorPageState();
}

class _ServiceEditorPageState extends State<ServiceEditorPage>
    with SingleTickerProviderStateMixin {
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
  late final AnimationController _entryController;

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
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _titleController.addListener(_onPreviewChanged);
    _descriptionController.addListener(_onPreviewChanged);
    _priceController.addListener(_onPreviewChanged);
    _tagsController.addListener(_onPreviewChanged);
    _serviceStore.loadServices();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onPreviewChanged);
    _descriptionController.removeListener(_onPreviewChanged);
    _priceController.removeListener(_onPreviewChanged);
    _tagsController.removeListener(_onPreviewChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onPreviewChanged() {
    if (mounted) {
      setState(() {});
    }
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorUserNotFound),
        ),
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

  List<String> get _selectedTags => _tagsController.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  List<String> get _availableTags {
    final tags = <String>{};
    for (final service in _serviceStore.services) {
      for (final tag in service.tags) {
        final normalized = tag.trim();
        if (normalized.isNotEmpty) tags.add(normalized);
      }
    }
    final result = tags.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result.take(18).toList();
  }

  void _toggleTag(String tag) {
    final current = _selectedTags;
    final exists = current.any((e) => e.toLowerCase() == tag.toLowerCase());
    setState(() {
      if (exists) {
        current.removeWhere((e) => e.toLowerCase() == tag.toLowerCase());
      } else {
        current.add(tag);
      }
      _tagsController.text = current.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? AppLocalizations.of(context)!.editTask
        : AppLocalizations.of(context)!.newTask;
    final buttonText = widget.isEditing
        ? AppLocalizations.of(context)!.updateTask
        : AppLocalizations.of(context)!.createTask;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
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
              _buildAnimatedSection(
                index: 0,
                child: AppPageHeader(
                  title: title,
                  subtitle: AppLocalizations.of(context)!.taskDetails,
                  icon: Icons.edit_note,
                ),
              ),
              _buildAnimatedSection(
                index: 1,
                child: GlassCard(
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
              ),
              const SizedBox(height: 12),
              _buildAnimatedSection(
                index: 2,
                child: _LiveServicePreviewCard(
                  title:
                      _titleController.text.trim().isEmpty
                          ? AppLocalizations.of(context)!.title
                          : _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  category: _selectedCategory.name.toUpperCase(),
                  price:
                      _priceController.text.trim().isEmpty
                          ? '—'
                          : _priceController.text.trim(),
                  currency: _selectedCurrency,
                  tags: _selectedTags,
                ),
              ),
              const SizedBox(height: 12),
              _buildAnimatedSection(
                index: 3,
                child: GlassCard(
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
                          inputFormatters: [LengthLimitingTextInputFormatter(80)],
                          maxLength: 80,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.title} *',
                          ),
                          validator:
                              (v) => v == null || v.trim().isEmpty
                                  ? AppLocalizations.of(context)!.enterTitle
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(700),
                          ],
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.description,
                          ),
                          maxLines: 3,
                          maxLength: 700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildAnimatedSection(
                index: 4,
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _priceController,
                          inputFormatters: [LengthLimitingTextInputFormatter(10)],
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.budget} *',
                          ),
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
                            if (parsed == null) {
                              return AppLocalizations.of(context)!.invalidBudget;
                            }
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(160),
                          ],
                          maxLength: 160,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.tags,
                            hintText: AppLocalizations.of(context)!.tagsHint,
                          ),
                        ),
                        Observer(
                          builder: (_) {
                            final tags = _availableTags;
                            if (tags.isEmpty) return const SizedBox.shrink();
                            final selected = _selectedTags
                                .map((e) => e.toLowerCase())
                                .toSet();
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tags.map((tag) {
                                  final isSelected = selected.contains(
                                    tag.toLowerCase(),
                                  );
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    showCheckmark: false,
                                    onSelected: (_) => _toggleTag(tag),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    selectedColor: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildAnimatedSection(
                index: 5,
                child: Observer(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.28).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}

class _LiveServicePreviewCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String price;
  final String currency;
  final List<String> tags;

  const _LiveServicePreviewCard({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Live card preview',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  title,
                  key: ValueKey('preview-title-$title'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (description.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    description,
                    key: ValueKey('preview-description-$description'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      '$price $currency',
                      key: ValueKey('preview-price-$price-$currency'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.take(3).map((tag) {
                    return Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(tag, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
