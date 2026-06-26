import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_list.dart';
import '../models/list_item.dart';
import '../models/template.dart';
import '../services/local_storage_service.dart';

const _uuid = Uuid();

// ─── All Grocery Lists ──────────────────────────────────────────

final groceryListsProvider =
    StateNotifierProvider<GroceryListsNotifier, List<GroceryList>>((ref) {
  return GroceryListsNotifier();
});

class GroceryListsNotifier extends StateNotifier<List<GroceryList>> {
  GroceryListsNotifier() : super([]) {
    _loadLists();
  }

  void _loadLists() {
    state = LocalStorageService.getAllLists();
  }

  void refresh() => _loadLists();

  Future<GroceryList> createList({
    required String name,
    double? budget,
    List<String>? categoryIds,
    String colorHex = '#2D5016',
    String? templateId,
  }) async {
    final list = GroceryList(
      id: _uuid.v4(),
      name: name.trim(),
      budget: budget,
      categoryIds: categoryIds,
      colorHex: colorHex,
      templateId: templateId,
    );
    await LocalStorageService.saveList(list);
    _loadLists();
    return list;
  }

  Future<GroceryList> createFromTemplate(ListTemplate template, {
    String? name,
    double? budget,
  }) async {
    final list = await createList(
      name: name ?? template.name,
      budget: budget,
      templateId: template.id,
    );

    // Add template items
    for (int i = 0; i < template.items.length; i++) {
      final tmplItem = template.items[i];
      final item = ListItem(
        id: _uuid.v4(),
        listId: list.id,
        name: tmplItem.name,
        quantity: tmplItem.quantity,
        unit: tmplItem.unit,
        categoryId: tmplItem.categoryId,
        unitPrice: tmplItem.unitPrice,
        sortOrder: i,
      );
      await LocalStorageService.saveItem(item);
    }

    _loadLists();
    return list;
  }

  Future<void> updateList(GroceryList list) async {
    await LocalStorageService.saveList(list);
    _loadLists();
  }

  Future<void> deleteList(String id) async {
    await LocalStorageService.deleteList(id);
    _loadLists();
  }

  Future<GroceryList> duplicateList(String id) async {
    final original = LocalStorageService.getList(id);
    if (original == null) throw Exception('List not found');

    final newList = await createList(
      name: '${original.name} (Copy)',
      budget: original.budget,
      categoryIds: List.from(original.categoryIds),
      colorHex: original.colorHex,
    );

    // Copy items
    final items = LocalStorageService.getItemsForList(id);
    for (final item in items) {
      final newItem = ListItem(
        id: _uuid.v4(),
        listId: newList.id,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.unitPrice,
        categoryId: item.categoryId,
        priority: item.priority,
        notes: item.notes,
        sortOrder: item.sortOrder,
      );
      await LocalStorageService.saveItem(newItem);
    }

    _loadLists();
    return newList;
  }
}

// ─── Selected List ──────────────────────────────────────────────

final selectedListIdProvider = StateProvider<String?>((ref) => null);

final selectedListProvider = Provider<GroceryList?>((ref) {
  final listId = ref.watch(selectedListIdProvider);
  if (listId == null) return null;
  final lists = ref.watch(groceryListsProvider);
  try {
    return lists.firstWhere((l) => l.id == listId);
  } catch (_) {
    return LocalStorageService.getList(listId);
  }
});
