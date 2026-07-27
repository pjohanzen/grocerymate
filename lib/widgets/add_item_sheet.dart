import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/list_item.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/validators.dart';
import '../utils/currency_formatter.dart';
import '../models/item_history.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  final String listId;
  final ListItem? editItem;

  const AddItemSheet({
    super.key,
    required this.listId,
    this.editItem,
  });

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedUnit = 'pcs';
  String? _selectedCategory;
  int _priority = 1;
  List<ItemHistory> _suggestions = [];
  bool _showSuggestions = false;

  bool get isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final item = widget.editItem!;
      _nameController.text = item.name;
      _quantityController.text = item.quantity.toStringAsFixed(
          item.quantity == item.quantity.roundToDouble() ? 0 : 1);
      if (item.unitPrice != null) {
        _priceController.text = item.unitPrice!.toStringAsFixed(0);
      }
      if (item.notes != null) _notesController.text = item.notes!;
      _selectedUnit = item.unit;
      _selectedCategory = item.categoryId;
      _priority = item.priority;
    } else {
      _quantityController.text = '1';
    }

    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _nameController.text;
    if (query.length >= 2) {
      setState(() {
        _suggestions = LocalStorageService.searchHistory(query);
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _estimatedCost {
    final qty = double.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[₱,]'), ''));
    if (qty != null && price != null) return qty * price;
    return null;
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Item' : 'Add Item',
                      style: AppTheme.headline2.copyWith(
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.neutral900,
                      ),
                    ),
                  ),
                  if (_estimatedCost != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        CurrencyFormatter.formatWhole(_estimatedCost!),
                        style: AppTheme.monoBold.copyWith(
                          color: AppTheme.success,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Item name with autocomplete
              Text('Item Name',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: Validators.validateItemName,
                style: AppTheme.bodyLarge.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g., Milk, Rice, Eggs',
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: !isEditing,
              ),
              // Suggestions dropdown
              if (_showSuggestions)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          suggestion.name,
                          style: AppTheme.bodyRegular.copyWith(
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.neutral900,
                          ),
                        ),
                        trailing: suggestion.lastPrice != null
                            ? Text(
                                CurrencyFormatter.formatWhole(suggestion.lastPrice!),
                                style: AppTheme.monoRegular.copyWith(fontSize: 12),
                              )
                            : null,
                        leading: Icon(Icons.history, size: 18,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral400),
                        onTap: () {
                          _nameController.text = suggestion.name;
                          if (suggestion.lastPrice != null) {
                            _priceController.text = suggestion.lastPrice!.toStringAsFixed(0);
                          } else {
                            _priceController.clear();
                          }
                          setState(() {
                            _showSuggestions = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity + Unit row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity',
                            style: AppTheme.label.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.neutral600,
                            )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          validator: Validators.validateQuantity,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: AppTheme.monoBold.copyWith(
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.neutral900,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit',
                            style: AppTheme.label.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.neutral600,
                            )),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          items: AppConstants.units.map((u) {
                            return DropdownMenuItem(value: u, child: Text(u));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.neutral900,
                          ),
                          dropdownColor: isDark
                              ? AppTheme.darkSurfaceHigh
                              : Colors.white,
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unit Price
              Text('Unit Price (optional)',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                validator: Validators.validatePrice,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTheme.monoBold.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: '₱0',
                  prefixText: '₱ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Category
              Text('Category',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                hint: Text('Select category',
                    style: AppTheme.bodyRegular.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral400,
                    )),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                style: AppTheme.bodyLarge.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                dropdownColor:
                    isDark ? AppTheme.darkSurfaceHigh : Colors.white,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // Priority
              Text('Priority',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(0, 'Low'),
                  const SizedBox(width: 8),
                  _buildPriorityChip(1, 'Normal'),
                  const SizedBox(width: 8),
                  _buildPriorityChip(2, 'High'),
                  const SizedBox(width: 8),
                  _buildPriorityChip(3, 'Urgent'),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              Text('Notes (optional)',
                  style: AppTheme.label.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral600,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                validator: Validators.validateNotes,
                maxLines: 2,
                maxLength: AppConstants.maxNotesLength,
                style: AppTheme.bodyRegular.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g., Brand X preferred',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),

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
                      child: Text(isEditing ? 'Save Changes' : 'Add Item'),
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

  Widget _buildPriorityChip(int level, String label) {
    final isSelected = _priority == level;
    final color = AppTheme.getPriorityColor(level);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkBorder
                      : AppTheme.neutral300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.label.copyWith(
                color: isSelected ? color : AppTheme.neutral500,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final qty = double.tryParse(_quantityController.text) ?? 1.0;
    final priceStr = _priceController.text.replaceAll(RegExp(r'[₱,]'), '');
    final price = priceStr.isEmpty ? null : double.tryParse(priceStr);
    final notes = _notesController.text.trim();

    if (isEditing) {
      final updated = widget.editItem!.copyWith(
        name: name,
        quantity: qty,
        unit: _selectedUnit,
        unitPrice: price,
        categoryId: _selectedCategory,
        priority: _priority,
        notes: notes.isEmpty ? null : notes,
      );
      ref.read(listItemsProvider(widget.listId).notifier).updateItem(updated);
    } else {
      ref.read(listItemsProvider(widget.listId).notifier).addItem(
            name: name,
            quantity: qty,
            unit: _selectedUnit,
            unitPrice: price,
            categoryId: _selectedCategory,
            priority: _priority,
            notes: notes.isEmpty ? null : notes,
          );
    }

    Navigator.pop(context);
  }
}
