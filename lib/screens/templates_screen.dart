import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/template.dart';
import '../providers/list_provider.dart';
import '../services/local_storage_service.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = LocalStorageService.getAllTemplates();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return _buildTemplateCard(context, ref, template, isDark);
        },
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    ListTemplate template,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _useTemplate(context, ref, template),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryLight.withValues(alpha: 0.15)
                            : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTemplateIcon(template.iconName),
                        size: 22,
                        color: isDark
                            ? AppTheme.primaryLight
                            : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                template.name,
                                style: AppTheme.headline3.copyWith(
                                  fontSize: 16,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.neutral900,
                                ),
                              ),
                              if (template.isPreset) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRESET',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.secondaryDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            template.description,
                            style: AppTheme.caption.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral400,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sample items
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: template.items.take(5).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceHigh
                            : AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.name,
                        style: AppTheme.caption.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.neutral600,
                        ),
                      ),
                    );
                  }).toList()
                    ..addAll(
                      template.items.length > 5
                          ? [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkSurfaceHigh
                                      : AppTheme.neutral200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${template.items.length - 5} more',
                                  style: AppTheme.caption.copyWith(
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.neutral400,
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
      ),
    );
  }

  void _useTemplate(BuildContext context, WidgetRef ref, ListTemplate template) {
    showDialog(
      context: context,
      builder: (context) {
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final budgetStr = budgetController.text.trim();
                final budget = budgetStr.isEmpty
                    ? null
                    : double.tryParse(budgetStr);

                ref.read(groceryListsProvider.notifier).createFromTemplate(
                      template,
                      name: name.isEmpty ? null : name,
                      budget: budget,
                    );

                Navigator.pop(context); // dialog
                Navigator.pop(context); // templates screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '"${name.isEmpty ? template.name : name}" created with ${template.items.length} items'),
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
        return Icons.calendar_today;
      case 'restaurant':
        return Icons.restaurant;
      case 'celebration':
        return Icons.celebration;
      case 'child_care':
        return Icons.child_care;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.shopping_cart;
    }
  }
}
