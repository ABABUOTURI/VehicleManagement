import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/Pages/Driver/DRiverVehicleRegistration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSlotsPage extends StatefulWidget {
  const ParkingSlotsPage({super.key});

  @override
  _ParkingSlotsPageState createState() => _ParkingSlotsPageState();
}

class _ParkingSlotsPageState extends State<ParkingSlotsPage> {
  late Box<ParkingSlot> parkingSlotBox;
  List<ParkingSlot> parkingSlots = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeBox();
    _syncWithFirestore(); // Sync Firestore data with local Hive storage
  }

  Future<void> _initializeBox() async {
    parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    _fetchParkingSlots();

    // Listen for changes in the Hive box and refresh the state
    parkingSlotBox.listenable().addListener(_fetchParkingSlots);
  }

  // Sync parking slots with Firestore
  Future<void> _syncWithFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('parkingSlots').get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        ParkingSlot slot = ParkingSlot(
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

        // Save or update the parking slot in Hive
        await parkingSlotBox.put(slot.slotId, slot);
      }
      print('Parking slots synchronized with Firestore');
    } catch (e) {
      print('Failed to sync with Firestore: $e');
    }
  }

  // Fetch parking slots from Hive
  void _fetchParkingSlots() {
    setState(() {
      parkingSlots = parkingSlotBox.values.toList();
    });
  }

  @override
  void dispose() {
    // Clean up the Hive listener when the widget is disposed
    parkingSlotBox.listenable().removeListener(_fetchParkingSlots);
    super.dispose();
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
                              assignedSlotId:
                                  slot.slotId, userEmail: '',), // Pass the assigned slot ID
                        ),
                      );
                      if (result == true) {
                        // Set slot as occupied and save to Hive
                        slot.isOccupied = true;
                        await parkingSlotBox.put(slot.slotId, slot);
                        _fetchParkingSlots();

                        // Also update Firestore with new slot status
                        await _firestore
                            .collection('parkingSlots')
                            .doc(slot.slotId.toString())
                            .set({
                          'slotId': slot.slotId,
                          'isOccupied': slot.isOccupied,
                          'checkInTime': DateTime.now().toIso8601String(),
                          'checkOutTime': slot.checkOutTime?.toIso8601String(),
                          'vehicleDetails': slot.vehicleDetails,
                          'ownerName': slot.ownerName,
                          'addedTime': slot.addedTime?.toIso8601String(),
                        }, SetOptions(merge: true));
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
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
