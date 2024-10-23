// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParkingSlotAdapter extends TypeAdapter<ParkingSlot> {
  @override
  final int typeId = 2;

  @override
  ParkingSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingSlot(
      slotId: fields[0] as String,
      isOccupied: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingSlot obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.slotId)
      ..writeByte(1)
      ..write(obj.isOccupied);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
