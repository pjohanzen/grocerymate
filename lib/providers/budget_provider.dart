import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

// ─── Budget Data for a List ─────────────────────────────────────

final budgetDataProvider =
    Provider.family<BudgetData, String>((ref, listId) {
  final list = LocalStorageService.getList(listId);
  if (list == null) return BudgetData.empty();

  final totalCost = LocalStorageService.getTotalCost(listId);
  final completedCost = LocalStorageService.getCompletedCost(listId);
  final budget = list.budget;
  final categorySpending = LocalStorageService.getCategorySpending(listId);

  return BudgetData(
    budget: budget,
    totalCost: totalCost,
    completedCost: completedCost,
    categorySpending: categorySpending,
  );
});

class BudgetData {
  final double? budget;
  final double totalCost;
  final double completedCost;
  final Map<String, double> categorySpending;

  const BudgetData({
    this.budget,
    required this.totalCost,
    required this.completedCost,
    required this.categorySpending,
  });

  factory BudgetData.empty() => const BudgetData(
        totalCost: 0,
        completedCost: 0,
        categorySpending: {},
      );

  bool get hasBudget => budget != null && budget! > 0;
  double get remaining => hasBudget ? budget! - totalCost : 0;
  double get percentage => hasBudget ? (totalCost / budget!).clamp(0.0, 2.0) : 0;
  bool get isOverBudget => hasBudget && totalCost > budget!;
  bool get isNearBudget => hasBudget && percentage >= 0.9 && !isOverBudget;

  String get statusLabel {
    if (!hasBudget) return 'No budget set';
    if (isOverBudget) return 'Over budget!';
    if (isNearBudget) return 'Almost at budget';
    return 'Within budget';
  }
}

// ─── Overall Budget Summary ─────────────────────────────────────

final overallBudgetProvider = Provider<OverallBudget>((ref) {
  final lists = LocalStorageService.getAllLists();
  double totalBudget = 0;
  double totalSpent = 0;

  for (final list in lists) {
    if (list.hasBudget) {
      totalBudget += list.budget!;
    }
    totalSpent += LocalStorageService.getTotalCost(list.id);
  }

  return OverallBudget(
    totalBudget: totalBudget,
    totalSpent: totalSpent,
    activeListCount: lists.length,
  );
});

class OverallBudget {
  final double totalBudget;
  final double totalSpent;
  final int activeListCount;

  const OverallBudget({
    required this.totalBudget,
    required this.totalSpent,
    required this.activeListCount,
  });

  double get remaining => totalBudget - totalSpent;
  double get percentage =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 2.0) : 0;
  bool get hasBudget => totalBudget > 0;
}
