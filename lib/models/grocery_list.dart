import 'package:hive/hive.dart';

part 'grocery_list.g.dart';

@HiveType(typeId: 0)
class GroceryList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double? budget;

  @HiveField(3)
  List<String> categoryIds;

  @HiveField(4)
  String colorHex;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  String? templateId;

  GroceryList({
    required this.id,
    required this.name,
    this.budget,
    List<String>? categoryIds,
    this.colorHex = '#2D5016',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.templateId,
  })  : categoryIds = categoryIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasBudget => budget != null && budget! > 0;

  GroceryList copyWith({
    String? name,
    double? budget,
    List<String>? categoryIds,
    String? colorHex,
    bool? isArchived,
    String? templateId,
  }) {
    return GroceryList(
      id: id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      categoryIds: categoryIds ?? this.categoryIds,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
      templateId: templateId ?? this.templateId,
    );
  }
}
