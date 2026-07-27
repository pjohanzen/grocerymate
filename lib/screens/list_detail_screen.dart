import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/list_item.dart';
import '../models/grocery_list.dart';
import '../models/category.dart';
import '../providers/list_provider.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../models/template.dart';
import '../utils/currency_formatter.dart';
import '../widgets/item_tile.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/create_list_sheet.dart';
import '../widgets/budget_progress_ring.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import 'barcode_scanner_screen.dart';
import 'receipt_ocr_screen.dart';
import 'checkout_screen.dart';
import '../services/export_service.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(searchQueryProvider(widget.listId).notifier).state = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider(widget.listId).notifier).state = query;
  }

  void _clearAllFilters() {
    ref.read(searchQueryProvider(widget.listId).notifier).state = '';
    ref.read(categoryFilterProvider(widget.listId).notifier).state = {};
    ref.read(statusFilterProvider(widget.listId).notifier).state =
        ItemStatusFilter.all;
    _searchController.clear();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final listId = widget.listId;
    final list = LocalStorageService.getList(listId);
    if (list == null) {
      return const Scaffold(body: Center(child: Text('List not found')));
    }

    final items = ref.watch(listItemsProvider(listId));
    final filteredGrouped = ref.watch(filteredGroupedItemsProvider(listId));
    final filteredItems = ref.watch(filteredItemsProvider(listId));
    final stats = ref.watch(listStatsProvider(listId));
    final hasFilters = ref.watch(hasActiveFiltersProvider(listId));
    final categories = ref.watch(categoriesProvider);
    final selectedCategories = ref.watch(categoryFilterProvider(listId));
    final statusFilter = ref.watch(statusFilterProvider(listId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCost = stats.totalCost;
    final budgetPercentage = list.hasBudget ? totalCost / list.budget! : 0.0;

    return Scaffold(
      appBar: _isSearching
          ? _buildSearchAppBar(isDark)
          : _buildNormalAppBar(list, items, listId),
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
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.05),
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
                                  color: AppTheme.getBudgetColor(
                                      budgetPercentage),
                                ),
                              ),
                              const SizedBox(height: 8),
                              BudgetProgressBar(
                                  percentage: budgetPercentage),
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

                // Filter bar: category chips + status filter
                if (items.length >= 3 || hasFilters)
                  _buildFilterBar(
                    isDark,
                    categories,
                    selectedCategories,
                    statusFilter,
                    listId,
                    hasFilters,
                  ),

                // Active filters indicator
                if (hasFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    color: isDark
                        ? AppTheme.primaryLight.withValues(alpha: 0.08)
                        : AppTheme.primary.withValues(alpha: 0.05),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 14,
                          color: isDark
                              ? AppTheme.primaryLight
                              : AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Showing ${filteredItems.length} of ${items.length} items',
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.primaryLight
                                : AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _clearAllFilters,
                          child: Text(
                            'Clear',
                            style: AppTheme.caption.copyWith(
                              color: isDark
                                  ? AppTheme.primaryLight
                                  : AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Items list grouped by category
                Expanded(
                  child: filteredGrouped.isEmpty && hasFilters
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.neutral400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No items match your filters',
                                style: AppTheme.bodyRegular.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.neutral500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearAllFilters,
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredGrouped.length,
                          itemBuilder: (context, index) {
                            final entry =
                                filteredGrouped.entries.elementAt(index);
                            final catId = entry.key;
                            final catItems = entry.value;
                            final category =
                                LocalStorageService.getCategory(catId);
                            final categoryName =
                                category?.name ?? 'Other';

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

  PreferredSizeWidget _buildSearchAppBar(bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          border: InputBorder.none,
          filled: false,
          hintStyle: AppTheme.bodyRegular.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          ),
      ],
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
      dynamic list, List<ListItem> items, String listId) {
    return AppBar(
      title: Text(list.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          tooltip: 'Scan Barcodes',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BarcodeScannerScreen(listId: listId),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.receipt_long_rounded),
          tooltip: 'Receipt OCR',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptOcrScreen(listId: listId),
              ),
            );
          },
        ),
        if (items.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search items',
            onPressed: _toggleSearch,
          ),
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
          onSelected: (value) async {
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
              case 'save_template':
                _saveAsTemplate(context, list, items);
                break;
              case 'export':
                if (items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot export an empty list. Add some items first.'),
                    ),
                  );
                } else {
                  _showExportSheet(context, list, items);
                }
                break;
              case 'uncheck_all':
                ref
                    .read(listItemsProvider(listId).notifier)
                    .toggleAllComplete(false);
                break;
              case 'check_all':
                ref
                    .read(listItemsProvider(listId).notifier)
                    .toggleAllComplete(true);
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
              value: 'save_template',
              child: ListTile(
                leading: Icon(Icons.bookmark_add_outlined),
                title: Text('Save as Template'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.share_outlined),
                title: Text('Export & Share'),
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
    );
  }

  Widget _buildFilterBar(
    bool isDark,
    List<Category> categories,
    Set<String> selectedCategories,
    ItemStatusFilter statusFilter,
    String listId,
    bool hasFilters,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.neutral200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatusChip('All', ItemStatusFilter.all, statusFilter, listId, isDark),
                const SizedBox(width: 8),
                _buildStatusChip('To Buy', ItemStatusFilter.toBuy, statusFilter, listId, isDark),
                const SizedBox(width: 8),
                _buildStatusChip('Completed', ItemStatusFilter.completed, statusFilter, listId, isDark),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Category chips
          CategoryChips(
            categories: categories,
            selectedIds: selectedCategories.toList(),
            onToggle: (catId) {
              final current = Set<String>.from(ref.read(categoryFilterProvider(listId)));
              if (current.contains(catId)) {
                current.remove(catId);
              } else {
                current.add(catId);
              }
              ref.read(categoryFilterProvider(listId).notifier).state = current;
            },
            scrollable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String label,
    ItemStatusFilter value,
    ItemStatusFilter current,
    String listId,
    bool isDark,
  ) {
    final isSelected = current == value;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      label: Text(label),
      labelStyle: AppTheme.caption.copyWith(
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : (isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        ref.read(statusFilterProvider(listId).notifier).state = value;
      },
      selectedColor: primaryColor,
      backgroundColor: isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
      side: BorderSide(
        color: isSelected ? primaryColor : (isDark ? AppTheme.darkBorder : AppTheme.neutral300),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
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
                    .read(listItemsProvider(widget.listId).notifier)
                    .toggleComplete(item.id);
              },
              onEdit: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      AddItemSheet(listId: widget.listId, editItem: item),
                );
              },
              onDelete: () {
                // Capture item data before deletion for undo
                final deletedName = item.name;
                final deletedQty = item.quantity;
                final deletedUnit = item.unit;
                final deletedPrice = item.unitPrice;
                final deletedCat = item.categoryId;
                final deletedPriority = item.priority;
                final deletedNotes = item.notes;

                ref
                    .read(listItemsProvider(widget.listId).notifier)
                    .deleteItem(item.id);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$deletedName deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(listItemsProvider(widget.listId).notifier)
                            .addItem(
                              name: deletedName,
                              quantity: deletedQty,
                              unit: deletedUnit,
                              unitPrice: deletedPrice,
                              categoryId: deletedCat,
                              priority: deletedPriority,
                              notes: deletedNotes,
                            );
                      },
                    ),
                    duration: const Duration(seconds: 5),
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

  void _showExportSheet(BuildContext context, GroceryList list, List<ListItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export & Share List',
                style: AppTheme.headline3.copyWith(
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primary),
                title: const Text('Export as PDF'),
                subtitle: const Text('Beautiful, shareable PDF document'),
                onTap: () async {
                  Navigator.pop(context);
                  final doc = await ExportService.generatePDF(list, items);
                  final bytes = await doc.save();
                  await ExportService.shareFile(
                    '',
                    '${list.name}.pdf',
                    'My Grocery List: ${list.name}',
                    isPDF: true,
                    pdfBytes: bytes,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_view_outlined, color: Colors.blue),
                title: const Text('Export as CSV'),
                subtitle: const Text('Spreadsheet compatible format (Excel, Sheets)'),
                onTap: () async {
                  Navigator.pop(context);
                  final csv = ExportService.exportToCSV(list, items);
                  await ExportService.shareFile(
                    csv,
                    '${list.name}.csv',
                    'My Grocery List: ${list.name}',
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.print_outlined, color: Colors.purple),
                title: const Text('Print List'),
                subtitle: const Text('Send directly to a connected printer'),
                onTap: () async {
                  Navigator.pop(context);
                  await ExportService.printPDF(list, items);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAsTemplate(BuildContext context, dynamic list, List<ListItem> items) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: '${list.name} Template');
        final descController = TextEditingController(text: 'Created from ${list.name}');

        return AlertDialog(
          title: const Text('Save as Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Template Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (name.isEmpty) return;

                final templateItems = items.map((item) => TemplateItem(
                  name: item.name,
                  quantity: item.quantity,
                  unit: item.unit,
                  categoryId: item.categoryId,
                  unitPrice: item.unitPrice,
                )).toList();

                final template = ListTemplate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  description: desc,
                  items: templateItems,
                  isPreset: false,
                  iconName: 'shopping_cart',
                );

                await LocalStorageService.saveTemplate(template);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved template "$name" successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
