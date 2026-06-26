// GENERATED CODE - hand-written Hive TypeAdapter for GroceryList

part of 'grocery_list.dart';

class GroceryListAdapter extends TypeAdapter<GroceryList> {
  @override
  final int typeId = 0;

  @override
  GroceryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryList(
      id: fields[0] as String,
      name: fields[1] as String,
      budget: fields[2] as double?,
      categoryIds: (fields[3] as List?)?.cast<String>() ?? [],
      colorHex: fields[4] as String? ?? '#2D5016',
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      isArchived: fields[7] as bool? ?? false,
      templateId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GroceryList obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.budget)
      ..writeByte(3)
      ..write(obj.categoryIds)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isArchived)
      ..writeByte(8)
      ..write(obj.templateId);
  }
}
