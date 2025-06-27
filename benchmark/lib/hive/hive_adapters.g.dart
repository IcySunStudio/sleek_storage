// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class TestModelBasicAdapter extends TypeAdapter<TestModelBasic> {
  @override
  final typeId = 1;

  @override
  TestModelBasic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestModelBasic(
      fieldZero: (fields[0] as num).toInt(),
      fieldOne: (fields[1] as num).toInt(),
      fieldTwo: (fields[2] as num).toInt(),
      fieldThree: (fields[3] as num).toInt(),
      fieldFour: (fields[4] as num).toInt(),
      fieldFive: (fields[5] as num).toInt(),
      fieldSix: (fields[6] as num).toInt(),
      fieldSeven: (fields[7] as num).toInt(),
      fieldEight: (fields[8] as num).toInt(),
      fieldNine: (fields[9] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, TestModelBasic obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.fieldZero)
      ..writeByte(1)
      ..write(obj.fieldOne)
      ..writeByte(2)
      ..write(obj.fieldTwo)
      ..writeByte(3)
      ..write(obj.fieldThree)
      ..writeByte(4)
      ..write(obj.fieldFour)
      ..writeByte(5)
      ..write(obj.fieldFive)
      ..writeByte(6)
      ..write(obj.fieldSix)
      ..writeByte(7)
      ..write(obj.fieldSeven)
      ..writeByte(8)
      ..write(obj.fieldEight)
      ..writeByte(9)
      ..write(obj.fieldNine);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModelBasicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestModelAdvancedHiveAdapterAdapter
    extends TypeAdapter<TestModelAdvancedHiveAdapter> {
  @override
  final typeId = 2;

  @override
  TestModelAdvancedHiveAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestModelAdvancedHiveAdapter(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestModelAdvancedHiveAdapter obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.encodedValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModelAdvancedHiveAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
