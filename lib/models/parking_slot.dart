import 'package:hive/hive.dart';

part 'parking_slot.g.dart';  // Hive will generate this file

@HiveType(typeId: 2)
class ParkingSlot extends HiveObject {
  @HiveField(0)
  String slotId;

  @HiveField(1)
  bool isOccupied;

  ParkingSlot({required this.slotId, required this.isOccupied});

  get duration => null;
}
