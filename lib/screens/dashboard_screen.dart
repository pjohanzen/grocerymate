import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';
import '../providers/list_provider.dart';
import '../widgets/create_list_sheet.dart';
import '../providers/item_provider.dart';
import '../widgets/dashboard/greeting_header.dart';
import '../widgets/dashboard/budget_overview_hero.dart';
import '../widgets/dashboard/quick_actions.dart';
import '../widgets/dashboard/upcoming_shopping.dart';
import '../widgets/dashboard/pantry_alerts.dart';
import '../widgets/dashboard/monthly_analytics.dart';
import '../widgets/dashboard/category_spending.dart';
import '../widgets/dashboard/most_purchased.dart';
import '../widgets/dashboard/recent_activity.dart';
import '../widgets/dashboard/smart_suggestions.dart';
import '../widgets/dashboard/shopping_streak.dart';
import '../widgets/dashboard/morphing_fab.dart';
import 'barcode_scanner_screen.dart';
import 'receipt_ocr_screen.dart';
import 'list_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    // Refresh lists and pantry providers
    ref.invalidate(groceryListsProvider);
    await Future.delayed(const Duration(milliseconds: 800));
  }



  void _showQuickAddDialog(BuildContext context, WidgetRef ref) {
    final lists = ref.read(groceryListsProvider);
    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a shopping list first!')),
      );
      return;
    }

    final textController = TextEditingController();
    String? selectedListId = lists.first.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Quick Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'e.g., Apple, Milk',
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedListId,
                    decoration: const InputDecoration(labelText: 'Target List'),
                    items: lists.map((l) {
                      return DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedListId = val;
                      });
                    },
                    dropdownColor: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
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
                    final name = textController.text.trim();
                    if (name.isNotEmpty && selectedListId != null) {
                      // Add item to list
                      ref.read(listItemsProvider(selectedListId!).notifier).addItem(
                            name: name,
                            quantity: 1.0,
                            unit: 'pcs',
                          );
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added "$name" successfully!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showListSelectorForAction(
    BuildContext context,
    List<dynamic> lists,
    String actionTitle,
    void Function(String listId) onSelected,
  ) {
    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a shopping list first!')),
      );
      return;
    }

    if (lists.length == 1) {
      onSelected(lists.first.id);
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
                  'Select Shopping List for $actionTitle',
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
                          color: _parseHexColor(list.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(list.name),
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelected(list.id);
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

  Color _parseHexColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final lists = ref.watch(groceryListsProvider);
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 640;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _handleRefresh(context, ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Greeting Header
                GreetingHeader(
                  greeting: stats.greeting,
                  dateText: stats.dateText,
                  motivationalMessage: stats.motivationalMessage,
                ),
                const SizedBox(height: 20),

                // RESPONSIVE LAYOUT ROUTING
                if (!isTablet) ...[
                  // Single Column Mobile Layout
                  BudgetOverviewHero(
                    totalBudget: stats.totalBudget,
                    totalSpent: stats.totalSpent,
                    remainingBudget: stats.remainingBudget,
                    budgetPercentage: stats.budgetPercentage,
                  ),
                  const SizedBox(height: 16),
                  QuickActionsGrid(
                    onNewList: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const CreateListSheet(),
                      );
                    },
                    onScanBarcode: () {
                      _showListSelectorForAction(context, lists, 'Barcode Scan', (listId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BarcodeScannerScreen(listId: listId),
                          ),
                        );
                      });
                    },
                    onScanReceipt: () {
                      _showListSelectorForAction(context, lists, 'Receipt OCR', (listId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReceiptOcrScreen(listId: listId),
                          ),
                        );
                      });
                    },
                    onTemplates: () {
                      ref.read(activeTabProvider.notifier).state = 3;
                    },
                  ),
                  const SizedBox(height: 16),
                  UpcomingShopping(
                    trip: stats.upcomingTrip,
                    onSchedulePressed: () {
                      _showListSelectorForAction(context, lists, 'Scheduling', (listId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListDetailScreen(listId: listId),
                          ),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PantryAlertsCard(
                    stats: stats.pantryAlerts,
                    onViewPantry: () {
                      ref.read(activeTabProvider.notifier).state = 2;
                    },
                  ),
                  const SizedBox(height: 16),
                  MonthlyAnalyticsCard(
                    monthlySpending: stats.monthlySpending,
                    weeklySpending: stats.weeklySpending,
                    averageTripCost: stats.averageTripCost,
                    mostExpensiveTrip: stats.mostExpensiveTrip,
                    moneySaved: stats.moneySaved,
                    averageItemCost: stats.averageItemCost,
                  ),
                  const SizedBox(height: 16),
                  CategorySpendingCard(slices: stats.categorySpending),
                  const SizedBox(height: 16),
                  MostPurchasedList(items: stats.topPurchasedItems),
                  const SizedBox(height: 16),
                  RecentActivityTimeline(activities: stats.recentActivities),
                  const SizedBox(height: 16),
                  SmartSuggestionsList(suggestions: stats.smartSuggestions),
                  const SizedBox(height: 16),
                  ShoppingStreakCard(
                    streakWeeks: stats.streakWeeks,
                    completedListsCount: stats.completedListsCount,
                    moneySaved: stats.totalMoneySavedHistorical,
                    completionRate: stats.completionRate,
                  ),
                ] else ...[
                  // Two-Column Grid Tablet Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            BudgetOverviewHero(
                              totalBudget: stats.totalBudget,
                              totalSpent: stats.totalSpent,
                              remainingBudget: stats.remainingBudget,
                              budgetPercentage: stats.budgetPercentage,
                            ),
                            const SizedBox(height: 16),
                            QuickActionsGrid(
                              onNewList: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const CreateListSheet(),
                                );
                              },
                              onScanBarcode: () {
                                _showListSelectorForAction(context, lists, 'Barcode Scan', (listId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BarcodeScannerScreen(listId: listId),
                                    ),
                                  );
                                });
                              },
                              onScanReceipt: () {
                                _showListSelectorForAction(context, lists, 'Receipt OCR', (listId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptOcrScreen(listId: listId),
                                    ),
                                  );
                                });
                              },
                              onTemplates: () {
                                ref.read(activeTabProvider.notifier).state = 3;
                              },
                            ),
                            const SizedBox(height: 16),
                            UpcomingShopping(
                              trip: stats.upcomingTrip,
                              onSchedulePressed: () {
                                _showListSelectorForAction(context, lists, 'Scheduling', (listId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ListDetailScreen(listId: listId),
                                    ),
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            RecentActivityTimeline(activities: stats.recentActivities),
                            const SizedBox(height: 16),
                            ShoppingStreakCard(
                              streakWeeks: stats.streakWeeks,
                              completedListsCount: stats.completedListsCount,
                              moneySaved: stats.totalMoneySavedHistorical,
                              completionRate: stats.completionRate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            PantryAlertsCard(
                              stats: stats.pantryAlerts,
                              onViewPantry: () {
                                ref.read(activeTabProvider.notifier).state = 2;
                              },
                            ),
                            const SizedBox(height: 16),
                            MonthlyAnalyticsCard(
                              monthlySpending: stats.monthlySpending,
                              weeklySpending: stats.weeklySpending,
                              averageTripCost: stats.averageTripCost,
                              mostExpensiveTrip: stats.mostExpensiveTrip,
                              moneySaved: stats.moneySaved,
                              averageItemCost: stats.averageItemCost,
                            ),
                            const SizedBox(height: 16),
                            CategorySpendingCard(slices: stats.categorySpending),
                            const SizedBox(height: 16),
                            MostPurchasedList(items: stats.topPurchasedItems),
                            const SizedBox(height: 16),
                            SmartSuggestionsList(suggestions: stats.smartSuggestions),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 80), // spacer for FAB overlay padding
              ],
            ),
          ),
        ),
      ),
      // Morphing floating action menu overlay FAB
      floatingActionButton: MorphingFab(
        onNewList: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreateListSheet(),
          );
        },
        onScanBarcode: () {
          _showListSelectorForAction(context, lists, 'Barcode Scan', (listId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BarcodeScannerScreen(listId: listId),
              ),
            );
          });
        },
        onScanReceipt: () {
          _showListSelectorForAction(context, lists, 'Receipt OCR', (listId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptOcrScreen(listId: listId),
              ),
            );
          });
        },
        onTemplates: () {
          ref.read(activeTabProvider.notifier).state = 3;
        },
        onQuickAddItem: () => _showQuickAddDialog(context, ref),
      ),
    );
  }
}
