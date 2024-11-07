import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class HiveAdminPage extends StatefulWidget {
  final ParkingSlot? slot;

  const HiveAdminPage({super.key, this.slot});

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

  Future<void> _registerVehicle(dynamic _phoneController, dynamic _vehicleColorController) async {
    if (_driverNameController.text.isNotEmpty &&
        _vehicleTypeController.text.isNotEmpty &&
        _licensePlateController.text.isNotEmpty) {
      try {
        var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
        var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');

        // Create a new Vehicle object
        Vehicle newVehicle = Vehicle(
          driverName: _driverNameController.text,
          vehicleType: _vehicleTypeController.text,
          licensePlate: _licensePlateController.text,
          timestamp: DateTime.now(),
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : 'N/A',
          slotId: widget.slot?.slotId ?? 0,
          vehicleColor: _vehicleColorController.text.isNotEmpty ? _vehicleColorController.text : 'Unknown', ticketId: '', email: '',
        );

        // Add the vehicle to the vehicles box
        await vehicleBox.add(newVehicle);

        // Mark the parking slot as occupied
         if (widget.slot != null) {
        var slotId = widget.slot!.slotId;
        var slot = parkingSlotBox.get(slotId);

        if (slot != null) {
          slot.isOccupied = true;
          await parkingSlotBox.put(slotId, slot); // Update the slot directly
        } else {
          // If slot doesn't exist, create a new entry
          var newSlot = ParkingSlot(slotId: slotId, isOccupied: true);
          await parkingSlotBox.add(newSlot);
        }
      }

        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Registered')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering vehicle: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  void _clearForm() {
    _driverNameController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
  }

  Widget _buildScrollableCard(String title, Widget content) {
    double cardWidth = MediaQuery.of(context).size.width - 32;
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 300,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive Database Admin"),
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildScrollableCard(
                  "Registered Users",
                  ValueListenableBuilder(
                    valueListenable: Hive.box<User>('users').listenable(),
                    builder: (context, Box<User> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text("No users found"));
                      }
                      return Column(
                        children: box.values.map((user) {
                          return ListTile(
                            title: Text('Name: ${user.name}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${user.email}'),
                                Text('Role: ${user.role}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await box.delete(user.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deleted')),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                _buildScrollableCard(
                  "Registered Vehicles",
                  ValueListenableBuilder(
                    valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
                    builder: (context, Box<Vehicle> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text("No vehicles found"));
                      }
                      return Column(
                        children: box.values.map((vehicle) {
                          return ListTile(
                            title: Text("${vehicle.vehicleType} - ${vehicle.licensePlate}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Driver: ${vehicle.driverName}'),
                                Text('Registered at: ${DateFormat('yyyy-MM-dd – kk:mm').format(vehicle.timestamp)}'),
                                Text('Phone: ${vehicle.phone}'),
                                Text('Slot ID: ${vehicle.slotId ?? 'N/A'}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await box.delete(vehicle.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vehicle deleted')),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                _buildScrollableCard(
                  "Parking Slots",
                  ValueListenableBuilder(
                    valueListenable: Hive.box<ParkingSlot>('parkingSlots').listenable(),
                    builder: (context, Box<ParkingSlot> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text("No parking slots available"));
                      }
                      return Column(
                        children: box.values.map((slot) {
                          return ListTile(
                            title: Text("Slot ${slot.slotId}"),
                            subtitle: Text(
                                'Status: ${slot.isOccupied ? 'Occupied' : 'Available'}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await box.delete(slot.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Parking slot deleted')),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                _buildScrollableCard(
                  "Payments and Receipts",
                  ValueListenableBuilder(
                    valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
                    builder: (context, Box<Vehicle> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text("No payment records found"));
                      }
                      return Column(
                        children: box.values.map((vehicle) {
                          return ListTile(
                            title: Text("Receipt for ${vehicle.licensePlate}"),
                            subtitle: Text(
                                'Driver: ${vehicle.driverName}, Amount Paid: Ksh${vehicle.paymentAmount ?? 0.0}'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
