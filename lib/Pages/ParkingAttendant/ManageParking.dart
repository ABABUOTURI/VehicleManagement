import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/vehicle.dart';

class PAManageParkingPage extends StatefulWidget {
  const PAManageParkingPage({super.key});

  @override
  _PAManageParkingPageState createState() => _PAManageParkingPageState();
}

class _PAManageParkingPageState extends State<PAManageParkingPage> {
  List<ParkingSlot> parkingSlots = [];
  bool isFull = false;

  @override
  void initState() {
    super.initState();
    _fetchParkingSlots();
  }

  // Fetch parking slot availability data
  Future<void> _fetchParkingSlots() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      parkingSlots = parkingSlotBox.values.toList();
      isFull = parkingSlots.every((slot) => slot.isOccupied == true);
    });
  }

  // Check-in a vehicle (mark slot as occupied)
  Future<void> _checkInVehicle(int slotId) async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    ParkingSlot? selectedSlot = parkingSlotBox.values
        .firstWhere((slot) => slot.slotId == slotId, orElse: () => null!);

    if (!selectedSlot.isOccupied) {
      selectedSlot.isOccupied = true;
      parkingSlotBox.put(slotId, selectedSlot);
      _fetchParkingSlots();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle checked in to slot $slotId')),
      );
    }
  }

  // Check-out a vehicle (mark slot as available)
  Future<void> _checkOutVehicle(int slotId) async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    ParkingSlot? selectedSlot = parkingSlotBox.values
        .firstWhere((slot) => slot.slotId == slotId, orElse: () => null!);

    if (selectedSlot.isOccupied) {
      selectedSlot.isOccupied = false;
      parkingSlotBox.put(slotId, selectedSlot);
      _fetchParkingSlots();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle checked out from slot $slotId')),
      );
    }
  }

  // Reserve a parking slot for VIP or specific users
  void _reserveSlot(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reserve Parking Slot $slotId"),
        content: const Text("Reserve this slot for VIP or specific user?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Slot $slotId reserved')),
              );
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  // Show alert if parking is full
  void _showFullCapacityAlert() {
    if (isFull) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Parking Full"),
          content: const Text("Parking is at full capacity. No available slots."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parking'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real-time Parking Availability
            const Text(
              'Parking Slot Availability',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid showing parking slots
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2.0,
                ),
                itemCount: parkingSlots.length,
                itemBuilder: (context, index) {
                  ParkingSlot slot = parkingSlots[index];
                  return Card(
                    color: slot.isOccupied ? Colors.red[300] : Colors.green[300],
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        if (!slot.isOccupied) {
                          _checkInVehicle(slot.slotId as int);
                        } else {
                          _checkOutVehicle(slot.slotId as int);
                        }
                      },
                      onLongPress: () {
                        _reserveSlot(slot.slotId as int);
                      },
                      child: Center(
                        child: Text(
                          'Slot ${slot.slotId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Alerts for full capacity
            if (isFull)
              Card(
                color: Colors.redAccent,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.white),
                  title: const Text(
                    'Parking is at full capacity!',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: Colors.white),
                    onPressed: _showFullCapacityAlert,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
