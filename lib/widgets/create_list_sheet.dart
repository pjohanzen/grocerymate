import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/list_provider.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/validators.dart';
import '../utils/extensions.dart';
import 'category_chips.dart';

class CreateListSheet extends ConsumerStatefulWidget {
  final String? editListId;

  const CreateListSheet({super.key, this.editListId});

  @override
  ConsumerState<CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends ConsumerState<CreateListSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  List<String> _selectedCategories = [];
  String _selectedColor = AppConstants.listColors.first;
  bool get isEditing => widget.editListId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final list = LocalStorageService.getList(widget.editListId!);
      if (list != null) {
        _nameController.text = list.name;
        if (list.hasBudget) {
          _budgetController.text = list.budget!.toStringAsFixed(0);
        }
        _selectedCategories = List.from(list.categoryIds);
        _selectedColor = list.colorHex;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                isEditing ? 'Edit List' : 'New List',
                style: AppTheme.headline2.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 24),

              // List name
              Text('List Name',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: Validators.validateListName,
                maxLength: AppConstants.maxListNameLength,
                style: AppTheme.bodyLarge.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g., Weekly Groceries',
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: !isEditing,
              ),
              const SizedBox(height: 20),

              // Budget
              Text('Budget (optional)',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                validator: Validators.validateBudget,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTheme.monoBold.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: '₱0.00',
                  prefixText: '₱ ',
                ),
              ),
              const SizedBox(height: 20),

              // Categories
              Text('Categories',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              CategoryChips(
                categories: categories,
                selectedIds: _selectedCategories,
                scrollable: false,
                onToggle: (id) {
                  setState(() {
                    if (_selectedCategories.contains(id)) {
                      _selectedCategories.remove(id);
                    } else {
                      _selectedCategories.add(id);
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Color picker
              Text('List Color',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              Row(
                children: AppConstants.listColors.map((hex) {
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: hex.toColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : AppTheme.neutral900)
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: hex.toColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Create List'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final budgetStr = _budgetController.text.trim().replaceAll(RegExp(r'[₱,]'), '');
    final budget = budgetStr.isEmpty ? null : double.tryParse(budgetStr);

    if (isEditing) {
      final list = LocalStorageService.getList(widget.editListId!);
      if (list != null) {
        final updated = list.copyWith(
          name: name,
          budget: budget,
          categoryIds: _selectedCategories,
          colorHex: _selectedColor,
        );
        ref.read(groceryListsProvider.notifier).updateList(updated);
      }
    } else {
      ref.read(groceryListsProvider.notifier).createList(
            name: name,
            budget: budget,
            categoryIds: _selectedCategories,
            colorHex: _selectedColor,
          );
    }

    Navigator.pop(context);
  }
}
