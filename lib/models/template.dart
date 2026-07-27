import 'package:hive/hive.dart';

part 'template.g.dart';

@HiveType(typeId: 3)
class TemplateItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final String? categoryId;

  @HiveField(4)
  final double? unitPrice;

  TemplateItem({
    required this.name,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.categoryId,
    this.unitPrice,
  });
}

@HiveType(typeId: 4)
class ListTemplate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<TemplateItem> items;

  @HiveField(4)
  bool isPreset;

  @HiveField(5)
  String iconName;

  @HiveField(6)
  final DateTime createdAt;

  ListTemplate({
    required this.id,
    required this.name,
    this.description = '',
    List<TemplateItem>? items,
    this.isPreset = false,
    this.iconName = 'shopping_cart',
    DateTime? createdAt,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now();

  static List<ListTemplate> get presets => [
        ListTemplate(
          id: 'weekly_staples',
          name: 'Weekly Staples',
          description: 'Common items for the week',
          isPreset: true,
          iconName: 'calendar_today',
          items: [
            TemplateItem(name: 'Rice', quantity: 5, unit: 'kg', categoryId: 'pantry'),
            TemplateItem(name: 'Eggs', quantity: 1, unit: 'dozen', categoryId: 'dairy'),
            TemplateItem(name: 'Milk', quantity: 1, unit: 'L', categoryId: 'dairy'),
            TemplateItem(name: 'Bread', quantity: 1, unit: 'pcs', categoryId: 'pantry'),
            TemplateItem(name: 'Chicken', quantity: 1, unit: 'kg', categoryId: 'meat'),
            TemplateItem(name: 'Garlic', quantity: 1, unit: 'pcs', categoryId: 'produce'),
            TemplateItem(name: 'Onions', quantity: 0.5, unit: 'kg', categoryId: 'produce'),
            TemplateItem(name: 'Tomatoes', quantity: 0.5, unit: 'kg', categoryId: 'produce'),
            TemplateItem(name: 'Cooking Oil', quantity: 1, unit: 'L', categoryId: 'pantry'),
            TemplateItem(name: 'Sugar', quantity: 1, unit: 'kg', categoryId: 'pantry'),
          ],
        ),
        ListTemplate(
          id: 'meal_prep',
          name: 'Meal Prep',
          description: 'Batch cooking essentials',
          isPreset: true,
          iconName: 'restaurant',
          items: [
            TemplateItem(name: 'Chicken Breast', quantity: 2, unit: 'kg', categoryId: 'meat'),
            TemplateItem(name: 'Brown Rice', quantity: 2, unit: 'kg', categoryId: 'pantry'),
            TemplateItem(name: 'Broccoli', quantity: 1, unit: 'kg', categoryId: 'produce'),
            TemplateItem(name: 'Bell Peppers', quantity: 6, unit: 'pcs', categoryId: 'produce'),
            TemplateItem(name: 'Sweet Potato', quantity: 1, unit: 'kg', categoryId: 'produce'),
            TemplateItem(name: 'Olive Oil', quantity: 1, unit: 'bottle', categoryId: 'pantry'),
            TemplateItem(name: 'Meal Containers', quantity: 1, unit: 'pack', categoryId: 'household'),
          ],
        ),
        ListTemplate(
          id: 'party',
          name: 'Party Planning',
          description: 'Snacks, drinks & party supplies',
          isPreset: true,
          iconName: 'celebration',
          items: [
            TemplateItem(name: 'Chips', quantity: 3, unit: 'bag', categoryId: 'pantry'),
            TemplateItem(name: 'Soft Drinks', quantity: 6, unit: 'bottle', categoryId: 'beverages'),
            TemplateItem(name: 'Juice', quantity: 3, unit: 'L', categoryId: 'beverages'),
            TemplateItem(name: 'Paper Plates', quantity: 1, unit: 'pack', categoryId: 'household'),
            TemplateItem(name: 'Paper Cups', quantity: 1, unit: 'pack', categoryId: 'household'),
            TemplateItem(name: 'Napkins', quantity: 1, unit: 'pack', categoryId: 'household'),
            TemplateItem(name: 'Ice', quantity: 2, unit: 'bag', categoryId: 'frozen'),
          ],
        ),
        ListTemplate(
          id: 'baby',
          name: 'Baby Essentials',
          description: 'Must-haves for the little one',
          isPreset: true,
          iconName: 'child_care',
          items: [
            TemplateItem(name: 'Diapers', quantity: 1, unit: 'pack', categoryId: 'baby'),
            TemplateItem(name: 'Baby Wipes', quantity: 2, unit: 'pack', categoryId: 'baby'),
            TemplateItem(name: 'Baby Formula', quantity: 1, unit: 'can', categoryId: 'baby'),
            TemplateItem(name: 'Baby Food', quantity: 6, unit: 'jar', categoryId: 'baby'),
            TemplateItem(name: 'Baby Shampoo', quantity: 1, unit: 'bottle', categoryId: 'baby'),
          ],
        ),
        ListTemplate(
          id: 'cleaning',
          name: 'Cleaning Day',
          description: 'Household cleaning supplies',
          isPreset: true,
          iconName: 'cleaning_services',
          items: [
            TemplateItem(name: 'Detergent', quantity: 1, unit: 'box', categoryId: 'household'),
            TemplateItem(name: 'Fabric Softener', quantity: 1, unit: 'bottle', categoryId: 'household'),
            TemplateItem(name: 'Dishwashing Liquid', quantity: 1, unit: 'bottle', categoryId: 'household'),
            TemplateItem(name: 'Floor Cleaner', quantity: 1, unit: 'bottle', categoryId: 'household'),
            TemplateItem(name: 'Sponges', quantity: 1, unit: 'pack', categoryId: 'household'),
            TemplateItem(name: 'Trash Bags', quantity: 1, unit: 'pack', categoryId: 'household'),
          ],
        ),
        ListTemplate(
          id: 'monthly_staples',
          name: 'Monthly Staples',
          description: 'Pantry restocking for the month',
          isPreset: true,
          iconName: 'calendar_today',
          items: [
            TemplateItem(name: 'Rice', quantity: 25, unit: 'kg', categoryId: 'pantry'),
            TemplateItem(name: 'Cooking Oil', quantity: 2, unit: 'L', categoryId: 'pantry'),
            TemplateItem(name: 'Sugar', quantity: 2, unit: 'kg', categoryId: 'pantry'),
            TemplateItem(name: 'Milk', quantity: 4, unit: 'L', categoryId: 'dairy'),
            TemplateItem(name: 'Laundry Detergent', quantity: 2, unit: 'box', categoryId: 'household'),
            TemplateItem(name: 'Toilet Paper', quantity: 1, unit: 'pack', categoryId: 'household'),
          ],
        ),
        ListTemplate(
          id: 'bbq_cookout',
          name: 'BBQ Cookout',
          description: 'Grilling essential meats & drinks',
          isPreset: true,
          iconName: 'restaurant',
          items: [
            TemplateItem(name: 'Pork Chop', quantity: 2, unit: 'kg', categoryId: 'meat'),
            TemplateItem(name: 'Hotdogs', quantity: 1, unit: 'pack', categoryId: 'meat'),
            TemplateItem(name: 'Soy Sauce', quantity: 1, unit: 'bottle', categoryId: 'pantry'),
            TemplateItem(name: 'Calamansi', quantity: 0.5, unit: 'kg', categoryId: 'produce'),
            TemplateItem(name: 'Charcoal', quantity: 2, unit: 'pack', categoryId: 'household'),
            TemplateItem(name: 'Soda', quantity: 4, unit: 'bottle', categoryId: 'beverages'),
          ],
        ),
        ListTemplate(
          id: 'christmas_feast',
          name: 'Christmas Feast',
          description: 'Traditional holiday dishes',
          isPreset: true,
          iconName: 'celebration',
          items: [
            TemplateItem(name: 'Ham', quantity: 1, unit: 'pcs', categoryId: 'meat'),
            TemplateItem(name: 'Spaghetti Pasta', quantity: 1, unit: 'kg', categoryId: 'pantry'),
            TemplateItem(name: 'Spaghetti Sauce', quantity: 1, unit: 'pack', categoryId: 'pantry'),
            TemplateItem(name: 'All Purpose Cream', quantity: 3, unit: 'pack', categoryId: 'dairy'),
            TemplateItem(name: 'Fruit Cocktail', quantity: 2, unit: 'can', categoryId: 'pantry'),
            TemplateItem(name: 'Condensed Milk', quantity: 2, unit: 'can', categoryId: 'dairy'),
            TemplateItem(name: 'Queso de Bola', quantity: 1, unit: 'pcs', categoryId: 'dairy'),
          ],
        ),
      ];
}
