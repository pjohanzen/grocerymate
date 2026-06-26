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
import 'list_detail_screen.dart';
import 'budget_screen.dart';
import 'templates_screen.dart';
import 'settings_screen.dart';

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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('GroceryMate',
                style: AppTheme.headline3.copyWith(
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                )),
          ],
        ),
        actions: [
          // Connectivity indicator
          if (!connectivity.isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.wifi_off,
                size: 18,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400,
              ),
            ),
          // Grid/List toggle
          IconButton(
            icon: Icon(
              viewMode == ListViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
            ),
            onPressed: () => ref.read(listViewModeProvider.notifier).toggle(),
          ),
          // More menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
            ),
            onSelected: (value) {
              switch (value) {
                case 'budget':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  );
                  break;
                case 'templates':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'budget',
                child: ListTile(
                  leading: Icon(Icons.pie_chart_outline),
                  title: Text('Budget Overview'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'templates',
                child: ListTile(
                  leading: Icon(Icons.copy_all),
                  title: Text('Templates'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
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
              icon: Icons.shopping_bag_outlined,
              title: 'No lists yet',
              subtitle: 'Tap the + button to create your first shopping list',
              buttonLabel: 'Create List',
              onAction: () => _showCreateSheet(context),
            )
          : CustomScrollView(
              slivers: [
                // Budget summary card
                SliverToBoxAdapter(
                  child: _buildBudgetSummary(context, isDark),
                ),
                // Lists
                if (viewMode == ListViewMode.grid)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildListItem(
                            context, ref, lists[index], true),
                        childCount: lists.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildListItem(
                              context, ref, lists[index], false),
                        ),
                        childCount: lists.length,
                      ),
                    ),
                  ),
                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New List'),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkSurfaceElevated, AppTheme.darkSurfaceHigh]
                : [AppTheme.primary.withValues(alpha: 0.06), AppTheme.primary.withValues(alpha: 0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: AppTheme.label.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalBudget > 0
                        ? CurrencyFormatter.formatBudgetDisplay(
                            totalSpent, totalBudget)
                        : CurrencyFormatter.formatWhole(totalSpent),
                    style: AppTheme.monoBold.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.neutral900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.getBudgetColor(percentage).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${lists.length} ${lists.length == 1 ? 'list' : 'lists'}',
                style: AppTheme.label.copyWith(
                  color: AppTheme.getBudgetColor(percentage),
                ),
              ),
            ),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit List'),
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
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate List'),
              onTap: () {
                Navigator.pop(context);
                ref.read(groceryListsProvider.notifier).duplicateList(list.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('List duplicated')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.error),
              title: Text('Delete List',
                  style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, list);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
            'Are you sure you want to delete "${list.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
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
}
