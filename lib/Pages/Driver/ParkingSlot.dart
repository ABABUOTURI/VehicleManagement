import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/Pages/Driver/DriverVehicleRegistration.dart';

class ParkingSlotsPage extends StatefulWidget {
  const ParkingSlotsPage({super.key});

  @override
  _ParkingSlotsPageState createState() => _ParkingSlotsPageState();
}

class _ParkingSlotsPageState extends State<ParkingSlotsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ParkingSlot> parkingSlots = [];

  @override
  void initState() {
    super.initState();
    _syncWithFirestore();
  }

  // Sync parking slots with Firestore
  Future<void> _syncWithFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('parkingSlots').get();

      setState(() {
        parkingSlots = snapshot.docs.map((doc) {
          var data = doc.data();
          return ParkingSlot(
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
        }).toList();
      });

      print('Parking slots synchronized with Firestore');
    } catch (e) {
      print('Failed to sync with Firestore: $e');
    }
  }

  // Handle checkout and make the slot free
  Future<void> _handleCheckOut(ParkingSlot slot) async {
    setState(() {
      slot.isOccupied = false; // Free the slot
      slot.checkOutTime = DateTime.now(); // Set checkout time
    });

    // Update the parking slot in Firestore
    await _firestore
        .collection('parkingSlots')
        .doc(slot.slotId.toString())
        .update({
      'isOccupied': false,
      'checkOutTime': slot.checkOutTime?.toIso8601String(),
    });

    // Show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked out from Slot ${slot.slotId}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSlots = parkingSlots.length;
    int bookedSlots = parkingSlots.where((slot) => slot.isOccupied).length;
    int availableSlots = totalSlots - bookedSlots;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Parking Spot!'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display total available and booked slots
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Total Available: $availableSlots',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Booked: $bookedSlots',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: parkingSlots.length,
              itemBuilder: (context, index) {
                final slot = parkingSlots[index];
                return GestureDetector(
                  onTap: () async {
                    // Show a message with the slot details when tapped
                    _showSlotSelectionMessage(slot);

                    if (!slot.isOccupied) {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingVehicleRegistrationPage(
                            assignedSlotId: slot.slotId,
                            userEmail: '',
                          ), // Pass the assigned slot ID
                        ),
                      );
                      if (result == true) {
                        // Set slot as occupied
                        slot.isOccupied = true;

                        // Update Firestore with new slot status
                        await _firestore
                            .collection('parkingSlots')
                            .doc(slot.slotId.toString())
                            .update({
                          'isOccupied': slot.isOccupied,
                          'checkInTime': DateTime.now().toIso8601String(),
                        });

                        // Refresh the slots list
                        _syncWithFirestore();
                      }
                    } else {
                      _showSlotOccupiedMessage();
                    }
                  },
                  child: ParkingSlotWidget(slot: slot),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show a message indicating which slot was selected
  void _showSlotSelectionMessage(ParkingSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You selected Slot ${slot.slotId}.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show message if a user tries to book an already occupied slot
  void _showSlotOccupiedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slot Unavailable'),
        content: const Text(
            'This slot is already booked. Please choose another slot.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ParkingSlotWidget extends StatelessWidget {
  final ParkingSlot slot;

  const ParkingSlotWidget({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    bool isBooked = slot.isOccupied;

    return Card(
      color: isBooked ? Colors.green : Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isBooked)
              const Text(
                'Occupied',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.directions_car, size: 40),
            const SizedBox(height: 8),
            Text(
              'Slot ${slot.slotId}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isBooked ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
