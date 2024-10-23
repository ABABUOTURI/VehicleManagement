import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/models/parking_slot.dart';

class ParkingSlotsPage extends StatefulWidget {
  const ParkingSlotsPage({super.key});

  @override
  _ParkingSlotsPageState createState() => _ParkingSlotsPageState();
}

class _ParkingSlotsPageState extends State<ParkingSlotsPage> {
  List<ParkingSlot> parkingSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchParkingSlots();
  }

  // Fetch parking slots from Hive or database
  Future<void> _fetchParkingSlots() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      parkingSlots = parkingSlotBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Parking Spot!'),
        backgroundColor: const Color(0xFF63D1F6),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to Profile Page or other actions
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Floors selection buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63D1F6),
                    ),
                    child: Text('1st Floor'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('2nd Floor'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('3rd Floor'),
                  ),
                ],
              ),
            ),

            // Parking slots display
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
              shrinkWrap: true, // Ensure GridView fits inside the SingleChildScrollView
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
                return ParkingSlotWidget(slot: slot);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // Continue to next action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF63D1F6),
          ),
          child: Text('Continue'),
        ),
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
              Image.asset('assets/vehicle.png', height: 40)
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
