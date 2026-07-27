import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/category.dart';
import '../providers/pantry_provider.dart';
import '../providers/list_provider.dart';
import '../providers/item_provider.dart';
import '../widgets/empty_state.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final pantryItems = ref.watch(pantryProvider);
    final categories = ref.watch(categoriesProvider);
    final lists = ref.watch(groceryListsProvider);

    // Filter items based on selected category chip
    final filteredItems = _selectedCategoryId == null
        ? pantryItems
        : pantryItems.where((item) => item.categoryId == _selectedCategoryId).toList();

    // Identify low/out-of-stock items for smart recommendations
    final suggestions = pantryItems.where((item) => item.quantity <= item.minStock).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pantry Inventory',
          style: AppTheme.headline2.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SMART RECOMMENDATIONS BANNER
          if (suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.primaryDark.withValues(alpha: 0.8), AppTheme.primary.withValues(alpha: 0.5)]
                      : [AppTheme.primary.withValues(alpha: 0.08), AppTheme.primaryLight.withValues(alpha: 0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${suggestions.length} items running low!',
                          style: AppTheme.headline3.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Add missing stocks directly to any shopping list.',
                          style: AppTheme.caption.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(80, 36),
                      textStyle: AppTheme.label.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAddSuggestionsToListSheet(context, suggestions, lists),
                    child: const Text('Add All'),
                  ),
                ],
              ),
            ),

          // CATEGORY FILTERS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: _selectedCategoryId == null,
                      showCheckmark: false,
                      label: const Text('All Items'),
                      labelStyle: AppTheme.caption.copyWith(
                        color: _selectedCategoryId == null
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
                        fontWeight: _selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                      side: BorderSide(
                        color: _selectedCategoryId == null
                            ? theme.colorScheme.primary
                            : (isDark ? AppTheme.darkBorder : AppTheme.neutral300),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (_) => setState(() => _selectedCategoryId = null),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Category.getIconData(cat.icon),
                              size: 14,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500),
                            ),
                            const SizedBox(width: 6),
                            Text(cat.name),
                          ],
                        ),
                        labelStyle: AppTheme.caption.copyWith(
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? AppTheme.darkBorder : AppTheme.neutral300),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // PANTRY ITEMS LIST
          Expanded(
            child: filteredItems.isEmpty
                ? EmptyState(
                    icon: Icons.kitchen_outlined,
                    title: 'Your Pantry is Empty',
                    subtitle: 'Add items manually or checkout lists to build up your stock.',
                    buttonLabel: 'Add Stock Item',
                    onAction: () => _showCreateEditPantrySheet(context),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildPantryItemCard(context, item, isDark, theme);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditPantrySheet(context),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
        label: Text(
          'Add Stock',
          style: AppTheme.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPantryItemCard(
    BuildContext context,
    PantryItemData item,
    bool isDark,
    ThemeData theme,
  ) {
    // Stock Status calculations
    Color statusColor = AppTheme.success;
    String statusLabel = 'In Stock';
    if (item.quantity == 0) {
      statusColor = AppTheme.error;
      statusLabel = 'Out of Stock';
    } else if (item.quantity <= item.minStock) {
      statusColor = AppTheme.warning;
      statusLabel = 'Low Stock';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTheme.headline3.copyWith(
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Stock status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: AppTheme.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Min. Alert Stock: ${item.minStock.toStringAsFixed(item.minStock == item.minStock.roundToDouble() ? 0 : 1)} ${item.unit}',
                        style: AppTheme.caption.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // RAPID STOCK INCREMENT CONTROLLER (high efficiency +/-)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                      onPressed: () {
                        if (item.quantity > 0) {
                          ref.read(pantryProvider.notifier).updatePantryItem(
                                item.copyWith(quantity: max(0.0, item.quantity - 1.0)),
                              );
                        }
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                        style: AppTheme.monoBold.copyWith(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                      onPressed: () {
                        ref.read(pantryProvider.notifier).updatePantryItem(
                              item.copyWith(quantity: item.quantity + 1.0),
                            );
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Card footer contextual options
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showCreateEditPantrySheet(context, item),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Edit Details'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(50, 32),
                    textStyle: AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => ref.read(pantryProvider.notifier).deletePantryItem(item.id),
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                  label: Text('Delete', style: TextStyle(color: AppTheme.error)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(50, 32),
                    textStyle: AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEditPantrySheet(BuildContext context, [PantryItemData? editItem]) {
    final isEditing = editItem != null;
    final nameController = TextEditingController(text: editItem?.name ?? '');
    final qtyController = TextEditingController(
      text: editItem == null ? '1' : editItem.quantity.toStringAsFixed(editItem.quantity == editItem.quantity.roundToDouble() ? 0 : 1),
    );
    final minStockController = TextEditingController(
      text: editItem == null ? '1' : editItem.minStock.toStringAsFixed(editItem.minStock == editItem.minStock.roundToDouble() ? 0 : 1),
    );
    String unit = editItem?.unit ?? 'pcs';
    String? categoryId = editItem?.categoryId;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.read(categoriesProvider);

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
                isEditing ? 'Edit Stock Details' : 'Add Pantry Stock Item',
                style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: 'Current Stock'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: ['pcs', 'kg', 'g', 'L', 'ml', 'box', 'pack', 'bottle', 'can', 'dozen'].map((u) {
                        return DropdownMenuItem(value: u, child: Text(u));
                      }).toList(),
                      onChanged: (val) {
                        unit = val ?? 'pcs';
                      },
                      dropdownColor: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                hint: const Text('Select category'),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                }).toList(),
                onChanged: (val) {
                  categoryId = val;
                },
                dropdownColor: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minStockController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Alert Stock Level',
                  helperText: 'Triggers "Low Stock" alert when current stock drops to or below this level.',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        final qty = double.tryParse(qtyController.text) ?? 1.0;
                        final minS = double.tryParse(minStockController.text) ?? 1.0;

                        if (name.isEmpty) return;

                        if (isEditing) {
                          final updated = editItem.copyWith(
                            name: name,
                            quantity: qty,
                            unit: unit,
                            categoryId: categoryId,
                            minStock: minS,
                          );
                          await ref.read(pantryProvider.notifier).updatePantryItem(updated);
                        } else {
                          await ref.read(pantryProvider.notifier).addPantryItem(
                                name: name,
                                quantity: qty,
                                unit: unit,
                                categoryId: categoryId,
                                minStock: minS,
                              );
                        }

                        if (context.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Save Stock'),
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

  void _showAddSuggestionsToListSheet(
    BuildContext context,
    List<PantryItemData> lowStockItems,
    List<dynamic> lists,
  ) {
    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a shopping list first!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Target Shopping List',
                  style: AppTheme.headline3.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (context, idx) {
                    final list = lists[idx];
                    return ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: (list.colorHex as String).toColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(list.name),
                      onTap: () {
                        // Quick-add all low stock items to this list
                        final listNotifier = ref.read(listItemsProvider(list.id).notifier);
                        int addedCount = 0;

                        for (final item in lowStockItems) {
                          // Standard import quantity is calculated as: minStock - current quantity (or default 1 if negative)
                          final neededQty = max(1.0, item.minStock - item.quantity);
                          listNotifier.addItem(
                            name: item.name,
                            quantity: neededQty,
                            unit: item.unit,
                            categoryId: item.categoryId,
                          );
                          addedCount++;
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $addedCount missing items to "${list.name}"!'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
extension on String {
  Color get toColor {
    final hex = replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
