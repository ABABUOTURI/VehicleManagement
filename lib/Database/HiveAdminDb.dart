import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class HiveAdminPage extends StatefulWidget {
  const HiveAdminPage({super.key});

  @override
  _HiveAdminPageState createState() => _HiveAdminPageState();
}

class _HiveAdminPageState extends State<HiveAdminPage> {
  final _driverNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();

  @override
  void dispose() {
    _driverNameController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  // Method to add a new vehicle and save to Hive
  Future<void> _registerVehicle() async {
    if (_driverNameController.text.isNotEmpty &&
        _vehicleTypeController.text.isNotEmpty &&
        _licensePlateController.text.isNotEmpty) {
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');

      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        vehicleType: _vehicleTypeController.text,
        licensePlate: _licensePlateController.text,
        timestamp: DateTime.now(), phone: '', slotId: null!, vehicleColor: '',
      );
      await vehicleBox.add(newVehicle);

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Registered')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  // Method to clear form fields
  void _clearForm() {
    _driverNameController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive Database Admin"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Section for Users
            const Text(
              "Registered Users",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<User>('users').listenable(),
              builder: (context, Box<User> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    User? user = box.getAt(index);
                    if (user == null) return const SizedBox.shrink();

                    return ListTile(
                      title: Text("User ${index + 1}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user.email}'),
                          Text('Name: ${user.name}'),
                          Text('Role: ${user.role}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await box.deleteAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User deleted')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Section for Registered Vehicles
            const Text(
              "Registered Vehicles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
              builder: (context, Box<Vehicle> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No vehicles found"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    Vehicle? vehicle = box.getAt(index);
                    if (vehicle == null) return const SizedBox.shrink();

                    return ListTile(
                      title: Text("${vehicle.vehicleType} - ${vehicle.licensePlate}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver: ${vehicle.driverName}'),
                          Text('Registered at: ${vehicle.timestamp}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await box.deleteAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vehicle deleted')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Section for Parking Slots
            const Text(
              "Parking Slots",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<ParkingSlot>('parkingSlots').listenable(),
              builder: (context, Box<ParkingSlot> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No parking slots available"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    ParkingSlot? slot = box.getAt(index);
                    if (slot == null) return const SizedBox.shrink();

                    return ListTile(
                      title: Text("Slot ${slot.slotId}"),
                      subtitle: Text(
                          'Status: ${slot.isOccupied ? 'Occupied' : 'Available'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await box.deleteAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Parking slot deleted')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
