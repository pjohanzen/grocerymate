import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_list.dart';
import '../models/list_item.dart';
import '../models/category.dart';
import '../models/template.dart';
import '../models/item_history.dart';
import '../config/constants.dart';
import 'notification_service.dart';

class LocalStorageService {
  static late Box<GroceryList> _listsBox;
  static late Box<ListItem> _itemsBox;
  static late Box<Category> _categoriesBox;
  static late Box<ListTemplate> _templatesBox;
  static late Box _settingsBox;
  static late Box _historyBox;
  static late Box _pantryBox;
  static late Box _barcodesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GroceryListAdapter());
    Hive.registerAdapter(ListItemAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TemplateItemAdapter());
    Hive.registerAdapter(ListTemplateAdapter());
    Hive.registerAdapter(ItemHistoryAdapter());

    // Open boxes
    _listsBox = await Hive.openBox<GroceryList>(AppConstants.listsBox);
    _itemsBox = await Hive.openBox<ListItem>(AppConstants.itemsBox);
    _categoriesBox = await Hive.openBox<Category>(AppConstants.categoriesBox);
    _templatesBox = await Hive.openBox<ListTemplate>(AppConstants.templatesBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _pantryBox = await Hive.openBox('pantry_items');
    _barcodesBox = await Hive.openBox('scanned_barcodes');

    // Seed defaults if first launch
    await _seedDefaults();
    await seedInitialPantryItems();
  }

  static Future<void> _seedDefaults() async {
    // Seed categories
    if (_categoriesBox.isEmpty) {
      for (final cat in Category.defaults) {
        await _categoriesBox.put(cat.id, cat);
      }
    }

    // Seed templates
    for (final tmpl in ListTemplate.presets) {
      if (!_templatesBox.containsKey(tmpl.id)) {
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

  static List<GroceryList> getAllListsIncludingArchived() {
    return _listsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static GroceryList? getList(String id) {
    return _listsBox.get(id);
  }

  static Future<void> saveList(GroceryList list) async {
    await _listsBox.put(list.id, list);
    await NotificationService.scheduleReminder(list);
  }

  static Future<void> deleteList(String id) async {
    await NotificationService.cancelReminder(id);
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
      await NotificationService.cancelReminder(id);
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
    await addToHistory(item.name, item.unitPrice);
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

  static Future<void> addToHistory(String itemName, [double? lastPrice]) async {
    final name = itemName.trim();
    if (name.isEmpty) return;
    final key = name.toLowerCase();
    final record = ItemHistory(
      name: name,
      lastPrice: lastPrice,
      lastUpdated: DateTime.now(),
    );
    await _historyBox.put(key, record);
  }

  static List<ItemHistory> searchHistory(String query) {
    final rawValues = _historyBox.values.toList();
    final List<ItemHistory> historyList = [];
    for (final val in rawValues) {
      if (val is String) {
        historyList.add(ItemHistory(
          name: val,
          lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        ));
      } else if (val is ItemHistory) {
        historyList.add(val);
      }
    }

    if (query.trim().isEmpty) {
      historyList.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      return historyList.take(10).toList();
    }

    final q = query.trim().toLowerCase();
    final matches = historyList.where((item) {
      return item.name.toLowerCase().contains(q);
    }).toList();

    matches.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aStartsWith = aName.startsWith(q);
      final bStartsWith = bName.startsWith(q);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return b.lastUpdated.compareTo(a.lastUpdated);
    });

    return matches.take(10).toList();
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
    await _pantryBox.clear();
    await _barcodesBox.clear();
    await _seedDefaults();
    await seedInitialPantryItems();
  }

  static int get totalListsCount => _listsBox.values.where((l) => !l.isArchived).length;
  static int get totalItemsCount => _itemsBox.length;

  // ─── Barcode Scanning ──────────────────────────────────────────

  static Map<dynamic, dynamic>? getBarcodeProduct(String barcode) {
    final offlineDB = {
      '4800003010123': {'name': 'Milo 22g', 'categoryId': 'beverages', 'price': 15.0},
      '4800003010456': {'name': 'Coca-Cola 1.5L', 'categoryId': 'beverages', 'price': 72.0},
      '4800012345678': {'name': 'Safeguard White 130g', 'categoryId': 'household', 'price': 54.0},
      '4800022334455': {'name': 'Gardenia Classic Loaf', 'categoryId': 'pantry', 'price': 85.0},
      '4800033445566': {'name': 'Century Tuna 180g', 'categoryId': 'pantry', 'price': 42.0},
      '4800044556677': {'name': 'Lucky Me! Pancit Canton', 'categoryId': 'pantry', 'price': 18.0},
    };

    if (offlineDB.containsKey(barcode)) {
      return offlineDB[barcode];
    }

    final stored = _barcodesBox.get(barcode);
    if (stored != null) {
      return Map<dynamic, dynamic>.from(stored);
    }

    return null;
  }

  static Future<void> saveBarcodeProduct(String barcode, Map<String, dynamic> product) async {
    await _barcodesBox.put(barcode, product);
  }

  // ─── Pantry Inventory ──────────────────────────────────────────

  static List<Map<dynamic, dynamic>> getAllPantryItems() {
    return _pantryBox.values.map((v) => Map<dynamic, dynamic>.from(v)).toList();
  }

  static Future<void> savePantryItem(Map<String, dynamic> item) async {
    await _pantryBox.put(item['id'], item);
  }

  static Future<void> deletePantryItem(String id) async {
    await _pantryBox.delete(id);
  }

  static Future<void> seedInitialPantryItems() async {
    if (_pantryBox.isEmpty) {
      final initialItems = [
        {'id': 'pantry_milk', 'name': 'Milk', 'quantity': 2.0, 'unit': 'L', 'categoryId': 'dairy', 'minStock': 1.0},
        {'id': 'pantry_eggs', 'name': 'Eggs', 'quantity': 12.0, 'unit': 'pcs', 'categoryId': 'dairy', 'minStock': 6.0},
        {'id': 'pantry_rice', 'name': 'Rice', 'quantity': 5.0, 'unit': 'kg', 'categoryId': 'pantry', 'minStock': 10.0},
        {'id': 'pantry_bread', 'name': 'Bread', 'quantity': 0.0, 'unit': 'pcs', 'categoryId': 'pantry', 'minStock': 1.0},
        {'id': 'pantry_chicken', 'name': 'Chicken Breast', 'quantity': 3.0, 'unit': 'kg', 'categoryId': 'meat', 'minStock': 1.5},
      ];
      for (final item in initialItems) {
        await _pantryBox.put(item['id'], item);
      }
    }
  }
}
