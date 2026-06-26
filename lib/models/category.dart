import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int sortOrder;

  @HiveField(4)
  bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
    this.isCustom = false,
  });

  Category copyWith({
    String? name,
    String? icon,
    int? sortOrder,
    bool? isCustom,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  static List<Category> get defaults => [
        Category(id: 'produce', name: 'Produce', icon: 'nutrition', sortOrder: 0),
        Category(id: 'dairy', name: 'Dairy', icon: 'water_drop', sortOrder: 1),
        Category(id: 'meat', name: 'Meat', icon: 'restaurant', sortOrder: 2),
        Category(id: 'pantry', name: 'Pantry', icon: 'kitchen', sortOrder: 3),
        Category(id: 'frozen', name: 'Frozen', icon: 'ac_unit', sortOrder: 4),
        Category(id: 'household', name: 'Household', icon: 'home', sortOrder: 5),
        Category(id: 'beverages', name: 'Beverages', icon: 'local_cafe', sortOrder: 6),
        Category(id: 'baby', name: 'Baby', icon: 'child_care', sortOrder: 7),
        Category(id: 'health', name: 'Health & Beauty', icon: 'favorite', sortOrder: 8),
        Category(id: 'other', name: 'Other', icon: 'more_horiz', sortOrder: 9),
      ];

  static IconData getIconData(String iconName) {
    final icons = <String, IconData>{
      'nutrition': const IconData(0xe532, fontFamily: 'MaterialIcons'),
      'water_drop': const IconData(0xe798, fontFamily: 'MaterialIcons'),
      'restaurant': const IconData(0xe56c, fontFamily: 'MaterialIcons'),
      'kitchen': const IconData(0xe51a, fontFamily: 'MaterialIcons'),
      'ac_unit': const IconData(0xe048, fontFamily: 'MaterialIcons'),
      'home': const IconData(0xe318, fontFamily: 'MaterialIcons'),
      'local_cafe': const IconData(0xe541, fontFamily: 'MaterialIcons'),
      'child_care': const IconData(0xe146, fontFamily: 'MaterialIcons'),
      'favorite': const IconData(0xe25b, fontFamily: 'MaterialIcons'),
      'more_horiz': const IconData(0xe5d3, fontFamily: 'MaterialIcons'),
      'shopping_cart': const IconData(0xe8cc, fontFamily: 'MaterialIcons'),
      'pets': const IconData(0xe91d, fontFamily: 'MaterialIcons'),
      'bakery_dining': const IconData(0xea53, fontFamily: 'MaterialIcons'),
    };
    return icons[iconName] ?? const IconData(0xe5d3, fontFamily: 'MaterialIcons');
  }
}
