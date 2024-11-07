import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 2)
class Vehicle extends HiveObject {
  @HiveField(0)
  String driverName;

  @HiveField(1)
  String vehicleType;

  @HiveField(2)
  String licensePlate;

  @HiveField(3)
  String vehicleColor;

  @HiveField(4)
  int slotId;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  String phone;

  @HiveField(7)
  double? paymentAmount;

  @HiveField(8)
  DateTime? checkOutTime;

  @HiveField(9) // New field for email
  String email; // Add the email field

  Vehicle({
    required this.driverName,
    required this.vehicleType,
    required this.licensePlate,
    required this.vehicleColor,
    required this.slotId,
    required this.timestamp,
    this.phone = '',
    this.paymentAmount,
    this.checkOutTime,
    required this.email, required String ticketId, // Add email to the constructor
  });
}
