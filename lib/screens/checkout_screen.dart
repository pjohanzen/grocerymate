import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/list_item.dart';
import '../models/category.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';
import '../providers/pantry_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String listId;

  const CheckoutScreen({super.key, required this.listId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  // Track which items were completed during this checkout session
  final Set<String> _sessionCompletedIds = {};
  // Budget at start for savings calculation
  double _startingCompletedCost = 0;
  bool _hasSyncedToPantry = false;

  // Animation controllers for swipe feedback
  late AnimationController _checkAnimController;
  late Animation<double> _checkScaleAnim;
  bool _showCheckOverlay = false;
  bool _checkOverlayIsComplete = true; // true=complete, false=skip

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScaleAnim = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
    _checkAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() => _showCheckOverlay = false);
            _checkAnimController.reset();
          }
        });
      }
    });

    // Capture starting completed cost for savings calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(listItemsProvider(widget.listId));
      _startingCompletedCost = items
          .where((i) => i.isCompleted)
          .fold(0.0, (sum, i) => sum + i.estimatedCost);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  void _markComplete(ListItem item) {
    ref
        .read(listItemsProvider(widget.listId).notifier)
        .toggleComplete(item.id);

    if (!item.isCompleted) {
      _sessionCompletedIds.add(item.id);
    } else {
      _sessionCompletedIds.remove(item.id);
    }

    // Show check overlay
    setState(() {
      _showCheckOverlay = true;
      _checkOverlayIsComplete = !item.isCompleted; // will be toggled
    });
    _checkAnimController.forward(from: 0);

    // Auto-advance after marking complete
    if (!item.isCompleted) {
      final items = ref.read(listItemsProvider(widget.listId));
      if (_currentPage < items.length - 1) {
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  void _skipItem() {
    final items = ref.read(listItemsProvider(widget.listId));
    if (_currentPage < items.length - 1) {
      // Show skip overlay
      setState(() {
        _showCheckOverlay = true;
        _checkOverlayIsComplete = false;
      });
      _checkAnimController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
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
    final totalEstimatedCost =
        allItems.fold(0.0, (sum, i) => sum + i.estimatedCost);

    if (allItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('No items')),
      );
    }

    // Check if all complete
    if (completedCount == totalItems) {
      if (!_hasSyncedToPantry) {
        _hasSyncedToPantry = true;
        // Schedule post-frame sync to avoid build cycle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(pantryProvider.notifier).syncListCheckoutToPantry(allItems);
        });
      }
      return _buildCompletionScreen(
        context,
        isDark,
        totalItems,
        completedCost,
        totalEstimatedCost,
        list,
      );
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

          // Running total bar
          _buildRunningTotalBar(
            isDark,
            completedCount,
            totalItems,
            completedCost,
            totalEstimatedCost,
            list,
          ),

          // Swipe hint
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_up_outlined,
                    size: 14,
                    color: isDark
                        ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
                        : AppTheme.neutral400),
                const SizedBox(width: 4),
                Text(
                  'Swipe up = done · Swipe down = skip',
                  style: AppTheme.caption.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
                        : AppTheme.neutral400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Item cards (swipe horizontally to navigate)
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return _buildSwipeableItemCard(
                        context, ref, item, isDark);
                  },
                ),
                // Check/Skip overlay animation
                if (_showCheckOverlay)
                  Center(
                    child: ScaleTransition(
                      scale: _checkScaleAnim,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _checkOverlayIsComplete
                              ? AppTheme.success.withValues(alpha: 0.9)
                              : AppTheme.warning.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_checkOverlayIsComplete
                                      ? AppTheme.success
                                      : AppTheme.warning)
                                  .withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _checkOverlayIsComplete
                              ? Icons.check
                              : Icons.skip_next,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
              ],
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
                      onPressed: () => _markComplete(currentItem),
                      icon: Icon(
                        currentItem.isCompleted ? Icons.undo : Icons.check,
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
                  // Next / Skip
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

  Widget _buildRunningTotalBar(
    bool isDark,
    int completedCount,
    int totalItems,
    double completedCost,
    double totalEstimatedCost,
    dynamic list,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
      child: Row(
        children: [
          // Left: items count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$completedCount of $totalItems items',
                style: AppTheme.bodyRegular.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutral500,
                ),
              ),
              if (totalEstimatedCost > 0)
                Text(
                  '${(completedCount / totalItems * 100).toStringAsFixed(0)}% done',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Right: cost info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              if (list != null && list.hasBudget)
                Text(
                  '${CurrencyFormatter.formatWhole(list.budget! - completedCost)} left',
                  style: AppTheme.caption.copyWith(
                    color: list.budget! >= completedCost
                        ? AppTheme.success
                        : AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableItemCard(
    BuildContext context,
    WidgetRef ref,
    ListItem item,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Dismissible(
          key: ValueKey('checkout_${item.id}'),
          direction: DismissDirection.vertical,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.up) {
              // Swipe up = mark complete
              _markComplete(item);
            } else {
              // Swipe down = skip
              _skipItem();
            }
            return false; // Don't actually dismiss the card
          },
          background: _buildVerticalSwipeBackground(
            isUp: false,
            color: AppTheme.warning,
            icon: Icons.skip_next,
            label: 'Skip',
            isDark: isDark,
          ),
          secondaryBackground: _buildVerticalSwipeBackground(
            isUp: true,
            color: AppTheme.success,
            icon: Icons.check_circle,
            label: 'Done!',
            isDark: isDark,
          ),
          child: _buildItemCardContent(item, isDark),
        ),
      ),
    );
  }

  Widget _buildVerticalSwipeBackground({
    required bool isUp,
    required Color color,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      alignment: isUp ? Alignment.bottomCenter : Alignment.topCenter,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.label.copyWith(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCardContent(ListItem item, bool isDark) {
    final category = item.categoryId != null
        ? LocalStorageService.getCategory(item.categoryId!)
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: item.isCompleted
            ? (isDark
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.successLight)
            : (isDark ? AppTheme.darkSurfaceElevated : Colors.white),
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
          // Category icon + name
          if (category != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceHigh
                    : AppTheme.neutral200.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Category.getIconData(category.icon),
                    size: 16,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.neutral500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: AppTheme.label.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
              color:
                  isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
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
            if (item.unitPrice != null &&
                item.quantity != 1.0) ...[
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.formatWhole(item.unitPrice!)} × ${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                      : AppTheme.neutral400,
                ),
              ),
            ],
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
                  const Icon(Icons.sticky_note_2_outlined,
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
    );
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    bool isDark,
    int totalItems,
    double completedCost,
    double totalEstimatedCost,
    dynamic list,
  ) {
    final sessionSpent = completedCost - _startingCompletedCost;
    final hasBudget = list != null && list.hasBudget;
    final budgetSaved =
        hasBudget ? list.budget! - completedCost : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.neutral100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration icon
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

                // Total spent card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceElevated
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        CurrencyFormatter.formatWhole(completedCost),
                        style: AppTheme.monoLarge.copyWith(
                          color: AppTheme.success,
                          fontSize: 36,
                        ),
                      ),
                      if (hasBudget) ...[
                        const SizedBox(height: 12),
                        Divider(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.neutral200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Budget: ${CurrencyFormatter.formatWhole(list.budget!)}',
                          style: AppTheme.bodyRegular.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.neutral500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Savings badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: budgetSaved >= 0
                                ? AppTheme.success.withValues(alpha: 0.12)
                                : AppTheme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                budgetSaved >= 0
                                    ? Icons.savings_outlined
                                    : Icons.warning_outlined,
                                color: budgetSaved >= 0
                                    ? AppTheme.success
                                    : AppTheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                budgetSaved >= 0
                                    ? 'You saved ${CurrencyFormatter.formatWhole(budgetSaved)} vs. budget!'
                                    : '${CurrencyFormatter.formatWhole(budgetSaved.abs())} over budget',
                                style: AppTheme.monoBold.copyWith(
                                  color: budgetSaved >= 0
                                      ? AppTheme.success
                                      : AppTheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Session stats card
                if (_sessionCompletedIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceElevated
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          'This Session',
                          '${_sessionCompletedIds.length} items',
                          isDark,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.neutral200,
                        ),
                        _buildStatColumn(
                          'Session Spent',
                          CurrencyFormatter.formatWhole(
                              sessionSpent > 0 ? sessionSpent : 0),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color:
                isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.monoBold.copyWith(
            color:
                isDark ? AppTheme.darkTextPrimary : AppTheme.neutral900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
