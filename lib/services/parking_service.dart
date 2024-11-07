import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle/models/parking_ticket.dart';
import 'package:vehicle/models/parking_slot.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save ParkingTicket to both Hive and Firestore
  Future<void> saveParkingTicket(ParkingTicket ticket) async {
    try {
      // Store in Hive
      var box = await Hive.openBox<ParkingTicket>('parkingTickets');
      await box.put(ticket.ticketNumber, ticket);
      print('Parking ticket stored locally in Hive');

      // Store in Firestore
      await _firestore
          .collection('parkingTickets')
          .doc(ticket.ticketNumber)
          .set({
        'ticketNumber': ticket.ticketNumber,
        'vehicleType': ticket.vehicleType,
        'isPaid': ticket.isPaid,
        'slotId': ticket.slotId,
        'issuedAt': ticket.issuedAt.toIso8601String(),
        'paidAt': ticket.paidAt?.toIso8601String(),
      });
      print('Parking ticket stored in Firestore');
    } catch (e) {
      print('Failed to store parking ticket: $e');
    }
  }

  // Retrieve ParkingTicket from either Hive or Firestore
  Future<ParkingTicket?> getParkingTicket(String ticketNumber) async {
    try {
      // Retrieve from Hive
      var box = await Hive.openBox<ParkingTicket>('parkingTickets');
      var ticket = box.get(ticketNumber);
      if (ticket != null) {
        print('Parking ticket retrieved from Hive');
        return ticket;
      }

      // Retrieve from Firestore if not found in Hive
      var snapshot =
          await _firestore.collection('parkingTickets').doc(ticketNumber).get();
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          var parkingTicket = ParkingTicket(
            ticketNumber: data['ticketNumber'] ?? '',
            vehicleType: data['vehicleType'] ?? '',
            isPaid: data['isPaid'] ?? false,
            slotId: data['slotId'] ?? 0,
            issuedAt: data['issuedAt'] != null
                ? DateTime.parse(data['issuedAt'])
                : DateTime.now(),
            paidAt:
                data['paidAt'] != null ? DateTime.parse(data['paidAt']) : null, ownerName: '', timestamp: '',
          );
          await box.put(
              ticketNumber, parkingTicket); // Store in Hive for future use
          print('Parking ticket retrieved from Firestore and stored in Hive');
          return parkingTicket;
        }
      } else {
        print('Parking ticket not found in Firestore');
      }
    } catch (e) {
      print('Failed to retrieve parking ticket: $e');
    }
    return null;
  }

  // Save ParkingSlot to both Hive and Firestore
  Future<void> saveParkingSlot(ParkingSlot slot) async {
    try {
      // Store in Hive
      var box = await Hive.openBox<ParkingSlot>('parkingSlots');
      await box.put(slot.slotId, slot);
      print('Parking slot stored locally in Hive');

      // Store in Firestore
      await _firestore
          .collection('parkingSlots')
          .doc(slot.slotId.toString())
          .set({
        'slotId': slot.slotId,
        'isOccupied': slot.isOccupied,
        'checkInTime': slot.checkInTime?.toIso8601String(),
        'checkOutTime': slot.checkOutTime?.toIso8601String(),
        'vehicleDetails': slot.vehicleDetails,
        'ownerName': slot.ownerName,
        'addedTime': slot.addedTime?.toIso8601String(),
      });
      print('Parking slot stored in Firestore');
    } catch (e) {
      print('Failed to store parking slot: $e');
    }
  }

  // Retrieve ParkingSlot from either Hive or Firestore
  Future<ParkingSlot?> getParkingSlot(int slotId) async {
    try {
      // Retrieve from Hive
      var box = await Hive.openBox<ParkingSlot>('parkingSlots');
      var slot = box.get(slotId);
      if (slot != null) {
        print('Parking slot retrieved from Hive');
        return slot;
      }

      // Retrieve from Firestore if not found in Hive
      var snapshot = await _firestore
          .collection('parkingSlots')
          .doc(slotId.toString())
          .get();
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          var parkingSlot = ParkingSlot(
            slotId: data['slotId'] ?? 0,
            isOccupied: data['isOccupied'] ?? false,
            checkInTime: data['checkInTime'] != null
                ? DateTime.parse(data['checkInTime'])
                : null,
            checkOutTime: data['checkOutTime'] != null
                ? DateTime.parse(data['checkOutTime'])
                : null,
            vehicleDetails: data['vehicleDetails'],
            ownerName: data['ownerName'],
            addedTime: data['addedTime'] != null
                ? DateTime.parse(data['addedTime'])
                : null,
          );
          await box.put(slotId, parkingSlot); // Store in Hive for future use
          print('Parking slot retrieved from Firestore and stored in Hive');
          return parkingSlot;
        }
      } else {
        print('Parking slot not found in Firestore');
      }
    } catch (e) {
      print('Failed to retrieve parking slot: $e');
    }
    return null;
  }
}
