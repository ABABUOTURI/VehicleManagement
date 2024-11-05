import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/Pages/Driver/DRiverVehicleRegistration.dart';

class ParkingSlotsPage extends StatefulWidget {
  const ParkingSlotsPage({super.key});

  @override
  _ParkingSlotsPageState createState() => _ParkingSlotsPageState();
}

class _ParkingSlotsPageState extends State<ParkingSlotsPage> {
  late Box<ParkingSlot> parkingSlotBox;
  List<ParkingSlot> parkingSlots = [];

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    _fetchParkingSlots();

    // Listen for changes in the Hive box and refresh the state
    parkingSlotBox.listenable().addListener(_fetchParkingSlots);
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
                    if (!slot.isOccupied) {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingVehicleRegistrationPage(),
                        ),
                      );
                      if (result == true) {
                        // Set slot as occupied and save to Hive
                        slot.isOccupied = true;
                        await parkingSlotBox.put(slot.slotId, slot);
                        _fetchParkingSlots();
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

  // Show message if a user tries to book an already occupied slot
  void _showSlotOccupiedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slot Unavailable'),
        content: const Text('This slot is already booked. Please choose another slot.'),
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
