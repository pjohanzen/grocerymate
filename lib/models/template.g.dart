// GENERATED CODE - hand-written Hive TypeAdapters for Template models

part of 'template.dart';

class TemplateItemAdapter extends TypeAdapter<TemplateItem> {
  @override
  final int typeId = 3;

  @override
  TemplateItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateItem(
      name: fields[0] as String,
      quantity: fields[1] as double? ?? 1.0,
      unit: fields[2] as String? ?? 'pcs',
      categoryId: fields[3] as String?,
      unitPrice: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.unitPrice);
  }
}

class ListTemplateAdapter extends TypeAdapter<ListTemplate> {
  @override
  final int typeId = 4;

  @override
  ListTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String? ?? '',
      items: (fields[3] as List?)?.cast<TemplateItem>() ?? [],
      isPreset: fields[4] as bool? ?? false,
      iconName: fields[5] as String? ?? 'shopping_cart',
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ListTemplate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.isPreset)
      ..writeByte(5)
      ..write(obj.iconName)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
