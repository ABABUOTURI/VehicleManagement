// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_ticket.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParkingTicketAdapter extends TypeAdapter<ParkingTicket> {
  @override
  final int typeId = 1;

  @override
  ParkingTicket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingTicket(
      ticketNumber: fields[0] as String,
      vehicleType: fields[1] as String,
      isPaid: fields[2] as bool,
      slotId: fields[3] as int,
      issuedAt: fields[4] as DateTime,
      paidAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingTicket obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ticketNumber)
      ..writeByte(1)
      ..write(obj.vehicleType)
      ..writeByte(2)
      ..write(obj.isPaid)
      ..writeByte(3)
      ..write(obj.slotId)
      ..writeByte(4)
      ..write(obj.issuedAt)
      ..writeByte(5)
      ..write(obj.paidAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingTicketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
