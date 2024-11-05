import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:intl/intl.dart';

class PAManageParkingPage extends StatefulWidget {
  const PAManageParkingPage({super.key});

  @override
  _PAManageParkingPageState createState() => _PAManageParkingPageState();
}

class _PAManageParkingPageState extends State<PAManageParkingPage> {
  late Box<ParkingSlot> parkingSlotBox;
  late Box<Vehicle> vehicleBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  // Open the Hive box and set up listeners
  Future<void> _openHiveBox() async {
    parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    setState(() {}); // Trigger initial UI update
  }

  // Method to display vehicle details and approve check-out
  Future<void> _showVehicleDetailsAndApproveCheckOut(int slotId) async {
    ParkingSlot? selectedSlot = parkingSlotBox.get(slotId);

    if (selectedSlot != null && selectedSlot.isOccupied) {
      // Find the vehicle parked in the slot
      Vehicle? vehicle;
try {
  vehicle = vehicleBox.values.firstWhere(
    (veh) => veh.slotId == slotId && veh.timestamp.isBefore(DateTime.now()),
  );
} catch (e) {
  // Handle the case where no matching element is found
  vehicle = null;
}

      if (vehicle != null) {
        // Display vehicle details and check-out prompt
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Details for Slot $slotId"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Driver Name: ${vehicle!.driverName}'),
                Text('License Plate: ${vehicle.licensePlate}'),
                Text('Check-in Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(vehicle.timestamp)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  selectedSlot.isOccupied = false;
                  selectedSlot.checkOutTime = DateTime.now();
                  await parkingSlotBox.put(slotId, selectedSlot);

                  setState(() {}); // Update the UI after the change
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vehicle checked out from slot $slotId')),
                  );
                },
                child: const Text("Approve Check-Out"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vehicle data found for this slot')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already available')),
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
        child: ValueListenableBuilder(
          valueListenable: Hive.box<ParkingSlot>('parkingSlots').listenable(),
          builder: (context, Box<ParkingSlot> box, _) {
            if (box.isEmpty) {
              return const Center(child: Text("No parking slots available"));
            }

            List<ParkingSlot> parkingSlots = box.values.toList();
            bool isFull = parkingSlots.every((slot) => slot.isOccupied);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parking Slot Availability',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
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
                      bool isOccupied = slot.isOccupied;

                      return Card(
                        color: isOccupied ? Colors.green[300] : Colors.yellow[300],
                        elevation: 4,
                        child: InkWell(
                          onTap: () {
                            if (isOccupied) {
                              _showVehicleDetailsAndApproveCheckOut(slot.slotId);
                            }
                          },
                          child: Center(
                            child: Text(
                              'Slot ${slot.slotId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isFull)
                  Card(
                    color: Colors.redAccent,
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.white),
                      title: const Text(
                        'Parking is at full capacity!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
