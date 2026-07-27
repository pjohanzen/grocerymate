import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/list_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../utils/currency_formatter.dart';
import '../services/local_storage_service.dart';
import '../widgets/list_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/create_list_sheet.dart';
import '../widgets/budget_progress_ring.dart';
import 'list_detail_screen.dart';
import 'budget_screen.dart';
import '../models/template.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(groceryListsProvider);
    final viewMode = ref.watch(listViewModeProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'GroceryMate',
              style: AppTheme.headline2.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (!connectivity.isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Offline Mode',
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 20,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              viewMode == ListViewMode.grid
                  ? Icons.reorder_rounded
                  : Icons.grid_view_rounded,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
            ),
            tooltip: viewMode == ListViewMode.grid ? 'List View' : 'Grid View',
            onPressed: () => ref.read(listViewModeProvider.notifier).toggle(),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              switch (value) {
                case 'budget':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'budget',
                child: ListTile(
                  leading: Icon(Icons.donut_large_rounded, color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral700),
                  title: const Text('Budget Overview'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: lists.isEmpty
          ? EmptyState(
              icon: Icons.local_mall_outlined,
              title: 'No lists yet',
              subtitle: 'Tap the button below or start from templates to make a grocery list.',
              buttonLabel: 'Create List',
              onAction: () => _showCreateSheet(context),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium dynamic budget cards
                SliverToBoxAdapter(
                  child: _buildBudgetSummary(context, isDark),
                ),
                // Bento Lists Layout
                if (viewMode == ListViewMode.grid)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.88,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 200 + (index * 50)),
                            curve: Curves.easeOutCubic,
                            builder: (context, animValue, child) {
                              return Opacity(
                                opacity: animValue,
                                child: Transform.translate(
                                  offset: Offset(0, 15 * (1.0 - animValue)),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildListItem(context, ref, lists[index], true),
                          );
                        },
                        childCount: lists.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 200 + (index * 50)),
                            curve: Curves.easeOutCubic,
                            builder: (context, animValue, child) {
                              return Opacity(
                                opacity: animValue,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1.0 - animValue)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildListItem(context, ref, lists[index], false),
                            ),
                          );
                        },
                        childCount: lists.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 96),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        elevation: 3,
        hoverElevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'New List',
          style: AppTheme.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(BuildContext context, bool isDark) {
    final lists = LocalStorageService.getAllLists();
    double totalBudget = 0;
    double totalSpent = 0;

    for (final list in lists) {
      if (list.hasBudget) totalBudget += list.budget!;
      totalSpent += LocalStorageService.getTotalCost(list.id);
    }

    if (totalBudget == 0 && totalSpent == 0) return const SizedBox.shrink();

    final percentage = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final isOverBudget = totalBudget > 0 && totalSpent > totalBudget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMBINED BUDGET OVERVIEW',
                        style: AppTheme.label.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalBudget > 0
                            ? CurrencyFormatter.formatBudgetDisplay(totalSpent, totalBudget)
                            : CurrencyFormatter.formatWhole(totalSpent),
                        style: AppTheme.monoBold.copyWith(
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isOverBudget ? AppTheme.error : AppTheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lists.length} ${lists.length == 1 ? 'list' : 'lists'}',
                    style: AppTheme.label.copyWith(
                      color: isOverBudget ? AppTheme.error : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (totalBudget > 0) ...[
              const SizedBox(height: 12),
              BudgetProgressBar(
                percentage: percentage,
                height: 6,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    WidgetRef ref,
    dynamic groceryList,
    bool isCompact,
  ) {
    return ListCard(
      groceryList: groceryList,
      isCompact: isCompact,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListDetailScreen(listId: groceryList.id),
          ),
        ).then((_) {
          ref.read(groceryListsProvider.notifier).refresh();
        });
      },
      onLongPress: () => _showListOptions(context, ref, groceryList),
    );
  }

  void _showListOptions(BuildContext context, WidgetRef ref, dynamic list) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mode_edit_outline_rounded),
                title: const Text('Edit List Details'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CreateListSheet(editListId: list.id),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text('Save as Reusable Template'),
                onTap: () {
                  Navigator.pop(context);
                  _saveAsTemplate(context, list);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
                title: Text(
                  'Delete List',
                  style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref, list);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text('Are you sure you want to delete "${list.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(groceryListsProvider.notifier).deleteList(list.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('List deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreateListSheet(),
    );
  }

  void _saveAsTemplate(BuildContext context, dynamic list) {
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

                final items = LocalStorageService.getItemsForList(list.id);
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
