class ParkingTicket {
  final String ticketNumber; // Immutable
  final String ownerName; // Immutable
  final String vehicleType; // Immutable
  final int slotId; // Immutable
  bool isPaid; // Mutable, can change its value
  DateTime? checkOutTime; // Nullable and mutable, can be set later
  DateTime? issuedAt; // Nullable, can be set later

  // Constructor
  ParkingTicket({
    required this.ticketNumber,
    required this.ownerName,
    required this.vehicleType,
    required this.slotId,
    required this.isPaid,
    this.checkOutTime, // Nullable parameter
    this.issuedAt, // Nullable parameter
  });
}
