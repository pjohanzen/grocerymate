import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/list_item.dart';
import '../models/category.dart';
import '../services/local_storage_service.dart';

const _uuid = Uuid();

// ─── Items for a Specific List ──────────────────────────────────

final listItemsProvider =
    StateNotifierProvider.family<ListItemsNotifier, List<ListItem>, String>(
  (ref, listId) => ListItemsNotifier(listId),
);

class ListItemsNotifier extends StateNotifier<List<ListItem>> {
  final String listId;

  ListItemsNotifier(this.listId) : super([]) {
    _loadItems();
  }

  void _loadItems() {
    state = LocalStorageService.getItemsForList(listId);
  }

  void refresh() => _loadItems();

  Future<ListItem> addItem({
    required String name,
    double quantity = 1.0,
    String unit = 'pcs',
    double? unitPrice,
    String? categoryId,
    int priority = 1,
    String? notes,
  }) async {
    final item = ListItem(
      id: _uuid.v4(),
      listId: listId,
      name: name.trim(),
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      categoryId: categoryId,
      priority: priority,
      notes: notes,
      sortOrder: state.length,
    );
    await LocalStorageService.saveItem(item);
    _loadItems();
    return item;
  }

  Future<void> updateItem(ListItem item) async {
    await LocalStorageService.saveItem(item);
    _loadItems();
  }

  Future<void> deleteItem(String itemId) async {
    await LocalStorageService.deleteItem(itemId);
    _loadItems();
  }

  Future<void> toggleComplete(String itemId) async {
    await LocalStorageService.toggleItemComplete(itemId);
    _loadItems();
  }

  Future<void> toggleAllComplete(bool complete) async {
    for (final item in state) {
      if (item.isCompleted != complete) {
        item.isCompleted = complete;
        item.updatedAt = DateTime.now();
        await item.save();
      }
    }
    _loadItems();
  }
}

// ─── Grouped Items by Category ──────────────────────────────────

final groupedItemsProvider =
    Provider.family<Map<String, List<ListItem>>, String>((ref, listId) {
  final items = ref.watch(listItemsProvider(listId));
  final grouped = <String, List<ListItem>>{};

  for (final item in items) {
    final catId = item.categoryId ?? 'other';
    grouped.putIfAbsent(catId, () => []);
    grouped[catId]!.add(item);
  }

  // Sort categories by default order
  final categories = LocalStorageService.getAllCategories();
  final catOrder = {for (final c in categories) c.id: c.sortOrder};

  final sorted = Map.fromEntries(
    grouped.entries.toList()
      ..sort((a, b) {
        final orderA = catOrder[a.key] ?? 999;
        final orderB = catOrder[b.key] ?? 999;
        return orderA.compareTo(orderB);
      }),
  );

  return sorted;
});

// ─── Item History / Autocomplete ────────────────────────────────

final itemHistoryProvider = Provider.family<List<String>, String>((ref, query) {
  return LocalStorageService.searchHistory(query);
});

// ─── List Statistics ────────────────────────────────────────────

final listStatsProvider = Provider.family<ListStats, String>((ref, listId) {
  final items = ref.watch(listItemsProvider(listId));
  final total = items.length;
  final completed = items.where((i) => i.isCompleted).length;
  final totalCost = items.fold(0.0, (sum, i) => sum + i.estimatedCost);
  final completedCost = items
      .where((i) => i.isCompleted)
      .fold(0.0, (sum, i) => sum + i.estimatedCost);

  return ListStats(
    totalItems: total,
    completedItems: completed,
    totalCost: totalCost,
    completedCost: completedCost,
  );
});

class ListStats {
  final int totalItems;
  final int completedItems;
  final double totalCost;
  final double completedCost;

  const ListStats({
    required this.totalItems,
    required this.completedItems,
    required this.totalCost,
    required this.completedCost,
  });

  int get remainingItems => totalItems - completedItems;
  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;
}

// ─── Categories Provider ────────────────────────────────────────

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = LocalStorageService.getAllCategories();
  }

  Future<void> addCategory(String name, String icon) async {
    final cat = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      sortOrder: state.length,
      isCustom: true,
    );
    await LocalStorageService.saveCategory(cat);
    _load();
  }

  Future<void> deleteCategory(String id) async {
    await LocalStorageService.deleteCategory(id);
    _load();
  }
}
