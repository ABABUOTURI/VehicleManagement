// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParkingSlotAdapter extends TypeAdapter<ParkingSlot> {
  @override
  final int typeId = 1;

  @override
  ParkingSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingSlot(
      slotId: fields[0] as int,
      isOccupied: fields[1] as bool,
      checkInTime: fields[2] as DateTime?,
      checkOutTime: fields[3] as DateTime?,
      vehicleDetails: fields[4] as String?,
      ownerName: fields[5] as String?,
      addedTime: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingSlot obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.slotId)
      ..writeByte(1)
      ..write(obj.isOccupied)
      ..writeByte(2)
      ..write(obj.checkInTime)
      ..writeByte(3)
      ..write(obj.checkOutTime)
      ..writeByte(4)
      ..write(obj.vehicleDetails)
      ..writeByte(5)
      ..write(obj.ownerName)
      ..writeByte(6)
      ..write(obj.addedTime);
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
