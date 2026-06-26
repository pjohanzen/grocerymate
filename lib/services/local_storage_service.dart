import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_list.dart';
import '../models/list_item.dart';
import '../models/category.dart';
import '../models/template.dart';
import '../config/constants.dart';

class LocalStorageService {
  static late Box<GroceryList> _listsBox;
  static late Box<ListItem> _itemsBox;
  static late Box<Category> _categoriesBox;
  static late Box<ListTemplate> _templatesBox;
  static late Box _settingsBox;
  static late Box<String> _historyBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GroceryListAdapter());
    Hive.registerAdapter(ListItemAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TemplateItemAdapter());
    Hive.registerAdapter(ListTemplateAdapter());

    // Open boxes
    _listsBox = await Hive.openBox<GroceryList>(AppConstants.listsBox);
    _itemsBox = await Hive.openBox<ListItem>(AppConstants.itemsBox);
    _categoriesBox = await Hive.openBox<Category>(AppConstants.categoriesBox);
    _templatesBox = await Hive.openBox<ListTemplate>(AppConstants.templatesBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _historyBox = await Hive.openBox<String>(AppConstants.historyBox);

    // Seed defaults if first launch
    await _seedDefaults();
  }

  static Future<void> _seedDefaults() async {
    // Seed categories
    if (_categoriesBox.isEmpty) {
      for (final cat in Category.defaults) {
        await _categoriesBox.put(cat.id, cat);
      }
    }

    // Seed templates
    if (_templatesBox.isEmpty) {
      for (final tmpl in ListTemplate.presets) {
        await _templatesBox.put(tmpl.id, tmpl);
      }
    }
  }

  // ─── Grocery Lists ────────────────────────────────────────────

  static List<GroceryList> getAllLists() {
    return _listsBox.values
        .where((list) => !list.isArchived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static GroceryList? getList(String id) {
    return _listsBox.get(id);
  }

  static Future<void> saveList(GroceryList list) async {
    await _listsBox.put(list.id, list);
  }

  static Future<void> deleteList(String id) async {
    // Delete all items in the list
    final items = getItemsForList(id);
    for (final item in items) {
      await _itemsBox.delete(item.id);
    }
    await _listsBox.delete(id);
  }

  static Future<void> archiveList(String id) async {
    final list = _listsBox.get(id);
    if (list != null) {
      list.isArchived = true;
      list.updatedAt = DateTime.now();
      await list.save();
    }
  }

  // ─── List Items ───────────────────────────────────────────────

  static List<ListItem> getItemsForList(String listId) {
    return _itemsBox.values
        .where((item) => item.listId == listId)
        .toList()
      ..sort((a, b) {
        // Completed items go to bottom
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Then by priority (high first)
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        // Then by sort order
        return a.sortOrder.compareTo(b.sortOrder);
      });
  }

  static Future<void> saveItem(ListItem item) async {
    await _itemsBox.put(item.id, item);
    // Update the list's updatedAt
    final list = _listsBox.get(item.listId);
    if (list != null) {
      list.updatedAt = DateTime.now();
      await list.save();
    }
    // Add to history
    await addToHistory(item.name);
  }

  static Future<void> deleteItem(String itemId) async {
    final item = _itemsBox.get(itemId);
    if (item != null) {
      final listId = item.listId;
      await _itemsBox.delete(itemId);
      // Update the list's updatedAt
      final list = _listsBox.get(listId);
      if (list != null) {
        list.updatedAt = DateTime.now();
        await list.save();
      }
    }
  }

  static Future<void> toggleItemComplete(String itemId) async {
    final item = _itemsBox.get(itemId);
    if (item != null) {
      item.isCompleted = !item.isCompleted;
      item.updatedAt = DateTime.now();
      await item.save();
    }
  }

  // ─── Categories ───────────────────────────────────────────────

  static List<Category> getAllCategories() {
    return _categoriesBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static Category? getCategory(String id) {
    return _categoriesBox.get(id);
  }

  static Future<void> saveCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // ─── Templates ────────────────────────────────────────────────

  static List<ListTemplate> getAllTemplates() {
    return _templatesBox.values.toList()
      ..sort((a, b) {
        // Presets first
        if (a.isPreset != b.isPreset) return a.isPreset ? -1 : 1;
        return a.name.compareTo(b.name);
      });
  }

  static Future<void> saveTemplate(ListTemplate template) async {
    await _templatesBox.put(template.id, template);
  }

  static Future<void> deleteTemplate(String id) async {
    await _templatesBox.delete(id);
  }

  // ─── Item History (Autocomplete) ──────────────────────────────

  static Future<void> addToHistory(String itemName) async {
    final name = itemName.trim().toLowerCase();
    if (name.isNotEmpty) {
      await _historyBox.put(name, itemName.trim());
    }
  }

  static List<String> searchHistory(String query) {
    if (query.trim().isEmpty) {
      return _historyBox.values.take(10).toList();
    }
    final q = query.toLowerCase();
    return _historyBox.values
        .where((name) => name.toLowerCase().contains(q))
        .take(10)
        .toList();
  }

  static Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // ─── Settings ─────────────────────────────────────────────────

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  // ─── Budget Calculations ──────────────────────────────────────

  static double getTotalCost(String listId) {
    return getItemsForList(listId)
        .fold(0.0, (sum, item) => sum + item.estimatedCost);
  }

  static double getCompletedCost(String listId) {
    return getItemsForList(listId)
        .where((item) => item.isCompleted)
        .fold(0.0, (sum, item) => sum + item.estimatedCost);
  }

  static Map<String, double> getCategorySpending(String listId) {
    final items = getItemsForList(listId);
    final spending = <String, double>{};
    for (final item in items) {
      final catId = item.categoryId ?? 'other';
      spending[catId] = (spending[catId] ?? 0) + item.estimatedCost;
    }
    return spending;
  }

  // ─── Data Management ─────────────────────────────────────────

  static Future<void> clearAllData() async {
    await _listsBox.clear();
    await _itemsBox.clear();
    await _categoriesBox.clear();
    await _templatesBox.clear();
    await _historyBox.clear();
    await _settingsBox.clear();
    await _seedDefaults();
  }

  static int get totalListsCount => _listsBox.values.where((l) => !l.isArchived).length;
  static int get totalItemsCount => _itemsBox.length;
}
