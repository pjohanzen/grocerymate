import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/grocery_list.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/extensions.dart';
import 'budget_progress_ring.dart';

class ListCard extends StatelessWidget {
  final GroceryList groceryList;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;

  const ListCard({
    super.key,
    required this.groceryList,
    required this.onTap,
    this.onLongPress,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = LocalStorageService.getItemsForList(groceryList.id);
    final totalItems = items.length;
    final completedItems = items.where((i) => i.isCompleted).length;
    final totalCost = items.fold(0.0, (sum, i) => sum + i.estimatedCost);
    final listColor = groceryList.colorHex.toColor;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color stripe
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: listColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            groceryList.name,
                            style: AppTheme.headline3.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.neutral900,
                              fontSize: isCompact ? 16 : 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (groceryList.hasBudget)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getBudgetColor(
                                groceryList.hasBudget
                                    ? totalCost / groceryList.budget!
                                    : 0,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              CurrencyFormatter.formatWhole(totalCost),
                              style: AppTheme.monoBold.copyWith(
                                fontSize: 12,
                                color: AppTheme.getBudgetColor(
                                  totalCost / groceryList.budget!,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress bar
                    if (totalItems > 0) ...[
                      BudgetProgressBar(
                        percentage: progress,
                        height: 6,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Stats row
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.neutral500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$completedItems / $totalItems items',
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          groceryList.updatedAt.timeAgo,
                          style: AppTheme.caption.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral400,
                          ),
                        ),
                      ],
                    ),

                    // Budget bar
                    if (groceryList.hasBudget && !isCompact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.formatBudgetDisplay(
                              totalCost,
                              groceryList.budget!,
                            ),
                            style: AppTheme.monoRegular.copyWith(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
