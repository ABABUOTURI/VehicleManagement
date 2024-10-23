import 'package:hive/hive.dart';

part 'vehicle.g.dart';  // Hive will generate this file

@HiveType(typeId: 1)
class Vehicle extends HiveObject {
  @HiveField(0)
  String driverName;

  @HiveField(1)
  String vehicleType;

  @HiveField(2)
  String licensePlate;

  @HiveField(3)
  DateTime timestamp;

  Vehicle({
    required this.driverName,
    required this.vehicleType,
    required this.licensePlate,
    required this.timestamp, required String phone, required int slotId, required String vehicleColor,
  });
}
