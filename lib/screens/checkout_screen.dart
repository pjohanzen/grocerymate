import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String listId;

  const CheckoutScreen({super.key, required this.listId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(listItemsProvider(widget.listId));
    final allItems = items.toList();
    final list = LocalStorageService.getList(widget.listId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = allItems.where((i) => i.isCompleted).length;
    final totalItems = allItems.length;
    final completedCost = allItems
        .where((i) => i.isCompleted)
        .fold(0.0, (sum, i) => sum + i.estimatedCost);

    if (allItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('No items')),
      );
    }

    // Check if all complete
    if (completedCount == totalItems) {
      return _buildCompletionScreen(
          context, isDark, totalItems, completedCost, list);
    }

    final currentItem =
        _currentPage < allItems.length ? allItems[_currentPage] : allItems.last;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.neutral100,
      appBar: AppBar(
        title: Text('${_currentPage + 1} / $totalItems'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: completedCount / totalItems,
            backgroundColor:
                isDark ? AppTheme.darkSurfaceHigh : AppTheme.neutral200,
            valueColor: const AlwaysStoppedAnimation(AppTheme.success),
            minHeight: 4,
          ),

          // Running total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount of $totalItems items',
                  style: AppTheme.bodyRegular.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral500,
                  ),
                ),
                if (list != null && list.hasBudget)
                  Text(
                    CurrencyFormatter.formatBudgetDisplay(
                        completedCost, list.budget!),
                    style: AppTheme.monoBold.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.neutral900,
                      fontSize: 14,
                    ),
                  )
                else
                  Text(
                    CurrencyFormatter.formatWhole(completedCost),
                    style: AppTheme.monoBold.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.neutral900,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Item cards (swipe)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                return _buildItemCard(context, ref, item, isDark);
              },
            ),
          ),

          // Bottom controls
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Previous
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentPage > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Prev'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mark complete / undo
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(
                                listItemsProvider(widget.listId).notifier)
                            .toggleComplete(currentItem.id);
                        // Auto-advance
                        if (!currentItem.isCompleted &&
                            _currentPage < allItems.length - 1) {
                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () {
                              if (mounted) {
                                _pageController.nextPage(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        }
                      },
                      icon: Icon(
                        currentItem.isCompleted
                            ? Icons.undo
                            : Icons.check,
                        size: 20,
                      ),
                      label: Text(
                        currentItem.isCompleted ? 'Undo' : 'Got It!',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentItem.isCompleted
                            ? AppTheme.warning
                            : AppTheme.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentPage < allItems.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: item.isCompleted
                ? (isDark
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.successLight)
                : (isDark
                    ? AppTheme.darkSurfaceElevated
                    : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: item.isCompleted
                  ? AppTheme.success.withValues(alpha: 0.3)
                  : (isDark ? AppTheme.darkBorder : AppTheme.neutral200),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Completed check
              if (item.isCompleted)
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppTheme.success,
                    size: 36,
                  ),
                ),

              // Item name
              Text(
                item.name,
                style: AppTheme.headline1.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.neutral900,
                  decoration:
                      item.isCompleted ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Quantity + unit
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurfaceHigh
                      : AppTheme.neutral200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                  style: AppTheme.monoBold.copyWith(
                    fontSize: 20,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.neutral700,
                  ),
                ),
              ),

              // Price
              if (item.hasPrice) ...[
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatWhole(item.estimatedCost),
                  style: AppTheme.monoLarge.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral500,
                  ),
                ),
              ],

              // Notes
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceHigh.withValues(alpha: 0.5)
                        : AppTheme.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 16, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.notes!,
                          style: AppTheme.bodyRegular.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    bool isDark,
    int totalItems,
    double totalCost,
    dynamic list,
  ) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.neutral100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'All Done! 🎉',
                  style: AppTheme.headline1.copyWith(
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.neutral900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalItems items purchased',
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral500,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceElevated
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Spent',
                        style: AppTheme.label.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.formatWhole(totalCost),
                        style: AppTheme.monoLarge.copyWith(
                          color: AppTheme.success,
                          fontSize: 36,
                        ),
                      ),
                      if (list != null && list.hasBudget) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Budget: ${CurrencyFormatter.formatWhole(list.budget!)}',
                          style: AppTheme.bodyRegular.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral500,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.formatWhole(list.budget! - totalCost)} saved',
                          style: AppTheme.monoBold.copyWith(
                            color: list.budget! >= totalCost
                                ? AppTheme.success
                                : AppTheme.error,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to List'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
