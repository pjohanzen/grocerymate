import 'package:hive/hive.dart';

part 'list_item.g.dart';

@HiveType(typeId: 1)
class ListItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String listId;

  @HiveField(2)
  String name;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  String unit;

  @HiveField(5)
  double? unitPrice;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  int priority; // 0=low, 1=normal, 2=high, 3=urgent

  @HiveField(9)
  String? notes;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  int sortOrder;

  ListItem({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.unitPrice,
    this.categoryId,
    this.isCompleted = false,
    this.priority = 1,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get estimatedCost => quantity * (unitPrice ?? 0);

  bool get hasPrice => unitPrice != null && unitPrice! > 0;

  ListItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? unitPrice,
    String? categoryId,
    bool? isCompleted,
    int? priority,
    String? notes,
    int? sortOrder,
  }) {
    return ListItem(
      id: id,
      listId: listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
