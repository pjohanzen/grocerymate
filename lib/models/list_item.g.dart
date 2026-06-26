// GENERATED CODE - hand-written Hive TypeAdapter for ListItem

part of 'list_item.dart';

class ListItemAdapter extends TypeAdapter<ListItem> {
  @override
  final int typeId = 1;

  @override
  ListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListItem(
      id: fields[0] as String,
      listId: fields[1] as String,
      name: fields[2] as String,
      quantity: fields[3] as double? ?? 1.0,
      unit: fields[4] as String? ?? 'pcs',
      unitPrice: fields[5] as double?,
      categoryId: fields[6] as String?,
      isCompleted: fields[7] as bool? ?? false,
      priority: fields[8] as int? ?? 1,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      sortOrder: fields[12] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ListItem obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.unitPrice)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.sortOrder);
  }
}
