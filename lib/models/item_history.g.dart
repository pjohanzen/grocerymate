// GENERATED CODE - hand-written Hive TypeAdapter for ItemHistory

part of 'item_history.dart';

class ItemHistoryAdapter extends TypeAdapter<ItemHistory> {
  @override
  final int typeId = 5;

  @override
  ItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemHistory(
      name: fields[0] as String,
      lastPrice: fields[1] as double?,
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ItemHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lastPrice)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }
}
