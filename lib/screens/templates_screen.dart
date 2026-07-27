import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';
import '../models/template.dart';
import '../providers/list_provider.dart';
import '../services/local_storage_service.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  List<ListTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    setState(() {
      _templates = LocalStorageService.getAllTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grocery Templates',
          style: AppTheme.headline2.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _templates.isEmpty
          ? const Center(child: Text('No templates available.'))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(context, template, isDark);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateCreateEditSheet(context),
        icon: const Icon(Icons.playlist_add_rounded, size: 24),
        label: Text(
          'New Template',
          style: AppTheme.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    ListTemplate template,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _useTemplate(context, template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: template.isPreset
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTemplateIcon(template.iconName),
                      size: 22,
                      color: template.isPreset ? AppTheme.primary : AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: AppTheme.headline3.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (template.isPreset ? AppTheme.primary : AppTheme.secondary).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                template.isPreset ? 'PRESET' : 'CUSTOM',
                                style: AppTheme.caption.copyWith(
                                  color: template.isPreset ? AppTheme.primary : AppTheme.secondaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          template.description,
                          style: AppTheme.bodyRegular.copyWith(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!template.isPreset) ...[
                    IconButton(
                      icon: const Icon(Icons.mode_edit_outline_rounded, size: 20),
                      onPressed: () => _showTemplateCreateEditSheet(context, template),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.error),
                      onPressed: () => _confirmDeleteTemplate(template),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              // Sample items display
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: template.items.take(4).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.name} (${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit})',
                      style: AppTheme.caption.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList()
                  ..addAll(
                    template.items.length > 4
                        ? [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${template.items.length - 4} more',
                                style: AppTheme.caption.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.8) : AppTheme.neutral500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTemplate(ListTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocalStorageService.deleteTemplate(template.id);
              _loadTemplates();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted template "${template.name}"')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTemplateCreateEditSheet(BuildContext context, [ListTemplate? editTemplate]) {
    final nameController = TextEditingController(text: editTemplate?.name ?? '');
    final descController = TextEditingController(text: editTemplate?.description ?? '');
    final isEditing = editTemplate != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Template' : 'New Custom Template',
                style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'e.g., Weekly Staples, BBQ Party',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Common items to buy for barbecue',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        if (name.isEmpty) return;

                        if (isEditing) {
                          editTemplate.name = name;
                          editTemplate.description = desc;
                          await LocalStorageService.saveTemplate(editTemplate);
                        } else {
                          final template = ListTemplate(
                            id: const Uuid().v4(),
                            name: name,
                            description: desc,
                            isPreset: false,
                            iconName: 'restaurant',
                            items: [], // user can fill items by saving list as template
                          );
                          await LocalStorageService.saveTemplate(template);
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadTemplates();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useTemplate(BuildContext context, ListTemplate template) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final nameController = TextEditingController(text: template.name);
        final budgetController = TextEditingController();

        return AlertDialog(
          title: Text('Create from "${template.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'List Name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (optional)',
                  prefixText: '₱ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final budgetStr = budgetController.text.trim();
                final budget = budgetStr.isEmpty ? null : double.tryParse(budgetStr);

                ref.read(groceryListsProvider.notifier).createFromTemplate(
                      template,
                      name: name.isEmpty ? null : name,
                      budget: budget,
                    );

                Navigator.pop(dialogCtx); // Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '"${name.isEmpty ? template.name : name}" created with ${template.items.length} items',
                    ),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  IconData _getTemplateIcon(String name) {
    switch (name) {
      case 'calendar_today':
        return Icons.calendar_today_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'celebration':
        return Icons.celebration_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }
}
