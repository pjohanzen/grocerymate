import 'package:hive/hive.dart';

part 'item_history.g.dart';

@HiveType(typeId: 5)
class ItemHistory extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double? lastPrice;

  @HiveField(2)
  final DateTime lastUpdated;

  ItemHistory({
    required this.name,
    this.lastPrice,
    required this.lastUpdated,
  });
}
