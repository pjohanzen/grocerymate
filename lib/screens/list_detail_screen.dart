import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/list_item.dart';
import '../models/category.dart';
import '../providers/list_provider.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/item_tile.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/create_list_sheet.dart';
import '../widgets/budget_progress_ring.dart';
import '../widgets/empty_state.dart';
import 'checkout_screen.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = LocalStorageService.getList(listId);
    if (list == null) {
      return const Scaffold(body: Center(child: Text('List not found')));
    }

    final items = ref.watch(listItemsProvider(listId));
    final groupedItems = ref.watch(groupedItemsProvider(listId));
    final stats = ref.watch(listStatsProvider(listId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCost = stats.totalCost;
    final budgetPercentage = list.hasBudget ? totalCost / list.budget! : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart_checkout),
              tooltip: 'Checkout Mode',
              onPressed: () {
                final uncompleted =
                    items.where((i) => !i.isCompleted).toList();
                if (uncompleted.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All items completed!')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(listId: listId),
                  ),
                ).then((_) {
                  ref.read(listItemsProvider(listId).notifier).refresh();
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CreateListSheet(editListId: listId),
                  ).then((_) {
                    ref.read(groceryListsProvider.notifier).refresh();
                  });
                  break;
                case 'uncheck_all':
                  ref.read(listItemsProvider(listId).notifier).toggleAllComplete(false);
                  break;
                case 'check_all':
                  ref.read(listItemsProvider(listId).notifier).toggleAllComplete(true);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit List'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'check_all',
                child: ListTile(
                  leading: Icon(Icons.check_box_outlined),
                  title: Text('Mark All Done'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'uncheck_all',
                child: ListTile(
                  leading: Icon(Icons.check_box_outline_blank),
                  title: Text('Uncheck All'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.add_shopping_cart,
              title: 'No items yet',
              subtitle: 'Tap the + button to add items to this list',
              buttonLabel: 'Add Item',
              onAction: () => _showAddItemSheet(context, listId),
            )
          : Column(
              children: [
                // Budget header
                if (list.hasBudget)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceElevated
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.formatBudgetDisplay(
                                    totalCost, list.budget!),
                                style: AppTheme.monoBold.copyWith(
                                  fontSize: 20,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.neutral900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${CurrencyFormatter.formatWhole(list.budget! - totalCost)} remaining',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.getBudgetColor(budgetPercentage),
                                ),
                              ),
                              const SizedBox(height: 8),
                              BudgetProgressBar(percentage: budgetPercentage),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${stats.completedItems}/${stats.totalItems}',
                          style: AppTheme.monoBold.copyWith(
                            fontSize: 14,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Items list grouped by category
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final entry = groupedItems.entries.elementAt(index);
                      final catId = entry.key;
                      final catItems = entry.value;
                      final category = LocalStorageService.getCategory(catId);
                      final categoryName = category?.name ?? 'Other';

                      return _buildCategorySection(
                        context,
                        ref,
                        catId,
                        categoryName,
                        category,
                        catItems,
                        isDark,
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context, listId),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    String catId,
    String categoryName,
    Category? category,
    List<ListItem> items,
    bool isDark,
  ) {
    final completedCount = items.where((i) => i.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              if (category != null) ...[
                Icon(
                  Category.getIconData(category.icon),
                  size: 18,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutral500,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                categoryName,
                style: AppTheme.label.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutral500,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completedCount/${items.length}',
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutral400,
                ),
              ),
              const Spacer(),
              // Category cost
              Text(
                CurrencyFormatter.formatWhole(
                  items.fold(0.0, (sum, i) => sum + i.estimatedCost),
                ),
                style: AppTheme.monoRegular.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutral400,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: isDark ? AppTheme.darkBorder : AppTheme.neutral200,
          height: 1,
        ),
        // Items
        ...items.map((item) => ItemTile(
              item: item,
              onToggle: () {
                ref
                    .read(listItemsProvider(listId).notifier)
                    .toggleComplete(item.id);
              },
              onEdit: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      AddItemSheet(listId: listId, editItem: item),
                );
              },
              onDelete: () {
                ref
                    .read(listItemsProvider(listId).notifier)
                    .deleteItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(listItemsProvider(listId).notifier)
                            .addItem(
                              name: item.name,
                              quantity: item.quantity,
                              unit: item.unit,
                              unitPrice: item.unitPrice,
                              categoryId: item.categoryId,
                              priority: item.priority,
                              notes: item.notes,
                            );
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            )),
      ],
    );
  }

  void _showAddItemSheet(BuildContext context, String listId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddItemSheet(listId: listId),
    );
  }
}
