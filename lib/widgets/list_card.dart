import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/grocery_list.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/extensions.dart';
import 'budget_progress_ring.dart';

class ListCard extends StatefulWidget {
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
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = LocalStorageService.getItemsForList(widget.groceryList.id);
    final totalItems = items.length;
    final completedItems = items.where((i) => i.isCompleted).length;
    final totalCost = items.fold(0.0, (sum, i) => sum + i.estimatedCost);
    final listColor = widget.groceryList.colorHex.toColor;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Left color accent bar (M3 inspired side-accent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(
                    color: listColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Budget Tag
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.groceryList.name,
                              style: AppTheme.headline3.copyWith(
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
                                fontSize: widget.isCompact ? 16 : 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.groceryList.hasBudget)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.getBudgetColor(
                                  totalCost / widget.groceryList.budget!,
                                ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.getBudgetColor(
                                    totalCost / widget.groceryList.budget!,
                                  ).withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                CurrencyFormatter.formatWhole(totalCost),
                                style: AppTheme.monoBold.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.getBudgetColor(
                                    totalCost / widget.groceryList.budget!,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      if (totalItems > 0) ...[
                        BudgetProgressBar(
                          percentage: progress,
                          height: 5,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Stats & Last Updated info
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$completedItems / $totalItems items',
                            style: AppTheme.caption.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.6) : AppTheme.neutral400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.groceryList.updatedAt.timeAgo,
                            style: AppTheme.caption.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral400,
                            ),
                          ),
                        ],
                      ),

                      // Budget allocation bar
                      if (widget.groceryList.hasBudget && !widget.isCompact) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 12),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.wallet_rounded,
                              size: 14,
                              color: isDark ? AppTheme.darkTextSecondary.withValues(alpha: 0.7) : AppTheme.neutral500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              CurrencyFormatter.formatBudgetDisplay(
                                totalCost,
                                widget.groceryList.budget!,
                              ),
                              style: AppTheme.monoRegular.copyWith(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
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
      ),
    );
  }
}
