import 'package:hive/hive.dart';

part 'parking_slot.g.dart';

@HiveType(typeId: 1)
class ParkingSlot extends HiveObject {
  @HiveField(0)
  int slotId;

  @HiveField(1)
  bool isOccupied;

  @HiveField(2)
  DateTime? checkInTime;

  @HiveField(3)
  DateTime? checkOutTime;

  @HiveField(4)
  String? vehicleDetails;

  @HiveField(5)
  String? ownerName;

  @HiveField(6)
  DateTime? addedTime;

  ParkingSlot({
    required this.slotId,
    this.isOccupied = false,
    this.checkInTime,
    this.checkOutTime,
    this.vehicleDetails,
    this.ownerName,
    this.addedTime,
  });
}
