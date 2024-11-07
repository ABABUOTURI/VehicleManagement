// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 2;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      driverName: fields[0] as String,
      vehicleType: fields[1] as String,
      licensePlate: fields[2] as String,
      vehicleColor: fields[3] as String,
      slotId: fields[4] as int,
      timestamp: fields[5] as DateTime,
      phone: fields[6] as String,
      paymentAmount: fields[7] as double?,
      checkOutTime: fields[8] as DateTime?, ticketId: '', email: '',
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.driverName)
      ..writeByte(1)
      ..write(obj.vehicleType)
      ..writeByte(2)
      ..write(obj.licensePlate)
      ..writeByte(3)
      ..write(obj.vehicleColor)
      ..writeByte(4)
      ..write(obj.slotId)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.paymentAmount)
      ..writeByte(8)
      ..write(obj.checkOutTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
