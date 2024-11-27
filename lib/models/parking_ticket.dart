import 'package:hive/hive.dart';

part 'parking_ticket.g.dart';

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
  late final DateTime issuedAt;

  @HiveField(5)
  final DateTime? paidAt; // Nullable field for when the ticket was paid

  @HiveField(6)
  late final DateTime? checkOutTime; // Added to track check out time

  @HiveField(7)
  final String ownerName; // Added to track owner name

  @HiveField(8)
  final String timestamp; // Ensure this is a String

  ParkingTicket({
    required this.ticketNumber,
    required this.vehicleType,
    required this.isPaid,
    required this.slotId,
    required this.issuedAt,
    this.paidAt,
    required this.ownerName,
    this.checkOutTime,
    required this.timestamp, // Add this field
  });

  // Method to create a ParkingTicket from a Map
  static ParkingTicket fromMap(Map<String, dynamic> data) {
    return ParkingTicket(
      ticketNumber: data['ticketId'] ?? '',
      vehicleType: data['vehicleType'] ?? '',
      isPaid: data['isPaid'] ?? false,
      slotId: data['slotId'] ?? 0,
      issuedAt:
          DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      paidAt: data['paidAt'] != null ? DateTime.parse(data['paidAt']) : null,
      ownerName: data['ownerName'] ?? '',
      checkOutTime: data['checkOutTime'] != null
          ? DateTime.parse(data['checkOutTime'])
          : null,
      timestamp: data['timestamp'] ??
          DateTime.now().toIso8601String(), // Ensure this is a valid string
    );
  }
}
