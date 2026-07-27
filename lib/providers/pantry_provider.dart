import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/local_storage_service.dart';
import '../models/list_item.dart';

class PantryItemData {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? categoryId;
  final double minStock;

  PantryItemData({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.categoryId,
    required this.minStock,
  });

  PantryItemData copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? categoryId,
    double? minStock,
  }) {
    return PantryItemData(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      minStock: minStock ?? this.minStock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'categoryId': categoryId,
      'minStock': minStock,
    };
  }

  factory PantryItemData.fromMap(Map<dynamic, dynamic> map) {
    return PantryItemData(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      categoryId: map['categoryId'] as String?,
      minStock: (map['minStock'] as num).toDouble(),
    );
  }
}

class PantryNotifier extends StateNotifier<List<PantryItemData>> {
  PantryNotifier() : super([]) {
    _loadPantry();
  }

  void _loadPantry() {
    final items = LocalStorageService.getAllPantryItems();
    state = items.map((map) => PantryItemData.fromMap(map)).toList();
  }

  Future<void> addPantryItem({
    required String name,
    required double quantity,
    required String unit,
    String? categoryId,
    required double minStock,
  }) async {
    final newItem = PantryItemData(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      categoryId: categoryId,
      minStock: minStock,
    );
    await LocalStorageService.savePantryItem(newItem.toMap());
    _loadPantry();
  }

  Future<void> updatePantryItem(PantryItemData item) async {
    await LocalStorageService.savePantryItem(item.toMap());
    _loadPantry();
  }

  Future<void> deletePantryItem(String id) async {
    await LocalStorageService.deletePantryItem(id);
    _loadPantry();
  }

  // Sync checked items from a completed shopping list to the pantry
  Future<void> syncListCheckoutToPantry(List<ListItem> checkedItems) async {
    for (final listItem in checkedItems) {
      if (!listItem.isCompleted) continue;

      // Find if item already exists in pantry
      final existingIndex = state.indexWhere(
        (p) => p.name.toLowerCase().trim() == listItem.name.toLowerCase().trim(),
      );

      if (existingIndex != -1) {
        final existing = state[existingIndex];
        final updated = existing.copyWith(
          quantity: existing.quantity + listItem.quantity,
        );
        await LocalStorageService.savePantryItem(updated.toMap());
      } else {
        // Create new item in pantry
        final newItem = PantryItemData(
          id: const Uuid().v4(),
          name: listItem.name,
          quantity: listItem.quantity,
          unit: listItem.unit,
          categoryId: listItem.categoryId,
          minStock: 1.0, // default min threshold
        );
        await LocalStorageService.savePantryItem(newItem.toMap());
      }
    }
    _loadPantry();
  }
}

final pantryProvider = StateNotifierProvider<PantryNotifier, List<PantryItemData>>((ref) {
  return PantryNotifier();
});
