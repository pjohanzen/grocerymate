import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../providers/list_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/budget_progress_ring.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(groceryListsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double totalBudget = 0;
    double totalSpent = 0;
    final Map<String, double> categorySpending = {};

    for (final list in lists) {
      if (list.hasBudget) totalBudget += list.budget!;
      final cost = LocalStorageService.getTotalCost(list.id);
      totalSpent += cost;

      final catSpend = LocalStorageService.getCategorySpending(list.id);
      for (final entry in catSpend.entries) {
        categorySpending[entry.key] =
            (categorySpending[entry.key] ?? 0) + entry.value;
      }
    }

    final percentage = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Overview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main ring
            Center(
              child: Column(
                children: [
                  BudgetProgressRing(
                    percentage: percentage,
                    spent: totalSpent,
                    budget: totalBudget > 0 ? totalBudget : null,
                    size: 200,
                    strokeWidth: 14,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    totalBudget > 0
                        ? CurrencyFormatter.formatBudgetDisplay(
                            totalSpent, totalBudget)
                        : CurrencyFormatter.formatWhole(totalSpent),
                    style: AppTheme.monoBold.copyWith(
                      fontSize: 22,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (totalBudget > 0)
                    Text(
                      '${CurrencyFormatter.formatWhole(totalBudget - totalSpent)} remaining',
                      style: AppTheme.bodyRegular.copyWith(
                        color: AppTheme.getBudgetColor(percentage),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Category breakdown
            Text(
              'Spending by Category',
              style: AppTheme.headline3.copyWith(
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.neutral900,
              ),
            ),
            const SizedBox(height: 16),

            if (categorySpending.isNotEmpty)
              _buildCategoryChart(context, categorySpending, totalSpent, isDark)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No spending data yet.\nAdd prices to your items to see a breakdown.',
                    style: AppTheme.bodyRegular.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Per-list breakdown
            Text(
              'By List',
              style: AppTheme.headline3.copyWith(
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ...lists.map((list) {
              final cost = LocalStorageService.getTotalCost(list.id);
              final itemCount =
                  LocalStorageService.getItemsForList(list.id).length;
              final listPercentage =
                  list.hasBudget ? cost / list.budget! : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurfaceElevated
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.neutral200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.name,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatWhole(cost),
                          style: AppTheme.monoBold.copyWith(
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.neutral900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$itemCount items',
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral500,
                          ),
                        ),
                        const Spacer(),
                        if (list.hasBudget)
                          Text(
                            'of ${CurrencyFormatter.formatWhole(list.budget!)}',
                            style: AppTheme.caption.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.neutral500,
                            ),
                          ),
                      ],
                    ),
                    if (list.hasBudget) ...[
                      const SizedBox(height: 8),
                      BudgetProgressBar(percentage: listPercentage),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    Map<String, double> spending,
    double total,
    bool isDark,
  ) {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.success,
      AppTheme.warning,
      const Color(0xFF6A1B9A),
      const Color(0xFF1565C0),
      AppTheme.error,
      const Color(0xFF00695C),
      const Color(0xFFF9A825),
      AppTheme.neutral500,
    ];

    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sortedEntries.asMap().entries.map((entry) {
                final colorIndex = entry.key % colors.length;
                final percent = total > 0
                    ? (entry.value.value / total * 100)
                    : 0.0;
                return PieChartSectionData(
                  value: entry.value.value,
                  color: colors[colorIndex],
                  title: '${percent.round()}%',
                  titleStyle: AppTheme.label.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  radius: 80,
                  titlePositionPercentageOffset: 0.6,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ...sortedEntries.asMap().entries.map((entry) {
          final colorIndex = entry.key % colors.length;
          final catId = entry.value.key;
          final amount = entry.value.value;
          final category = LocalStorageService.getCategory(catId);
          final name = category?.name ?? 'Other';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[colorIndex],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: AppTheme.bodyRegular.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.neutral900,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatWhole(amount),
                  style: AppTheme.monoBold.copyWith(
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.neutral900,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
