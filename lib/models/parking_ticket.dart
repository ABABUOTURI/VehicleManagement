import 'package:hive/hive.dart';

part 'parking_ticket.g.dart'; // This part is required for Hive TypeAdapter generation

@HiveType(typeId: 1) // Define a unique typeId for this model
class ParkingTicket {
  @HiveField(0)
  final String ticketNumber;

  @HiveField(1)
  final String vehicleType;

  @HiveField(2)
  final bool isPaid;

  @HiveField(3)
  final int slotId;

  @HiveField(4)
  final DateTime issuedAt;

  @HiveField(5)
  final DateTime? paidAt; // Nullable field for when the ticket was paid

  ParkingTicket({
    required this.ticketNumber,
    required this.vehicleType,
    required this.isPaid,
    required this.slotId,
    required this.issuedAt,
    this.paidAt,
  });

  DateTime get timestamp => null!;
}
