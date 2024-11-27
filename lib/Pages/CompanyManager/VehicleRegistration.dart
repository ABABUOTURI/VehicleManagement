import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/vehicle.dart'; // Ensure Vehicle model is imported

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key, required ParkingSlot parkingSlot});

  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _licensePlateController =
      TextEditingController();

  @override
  void dispose() {
    _driverNameController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  // Method to add a new vehicle and save to Hive
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      // Create a new Vehicle object with a timestamp
      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        vehicleType: _vehicleTypeController.text,
        licensePlate: _licensePlateController.text,
        timestamp: DateTime.now(), phone: '', slotId: null!, vehicleColor: '', ticketId: '', email: '',
      );

      // Open Hive box for vehicles and save the new vehicle
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      await vehicleBox.add(newVehicle);

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Registered')),
      );
    }
  }

  // Method to clear form fields after submission
  void _clearForm() {
    _driverNameController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
  }

  // Method to delete a registered vehicle from Hive
  Future<void> _deleteVehicle(int index) async {
    var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    await vehicleBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle deleted')),
    );
  }

  // Method to edit a vehicle (load data into form)
  void _editVehicle(int index) async {
    var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    Vehicle? vehicle = vehicleBox.getAt(index);
    if (vehicle != null) {
      setState(() {
        _driverNameController.text = vehicle.driverName;
        _vehicleTypeController.text = vehicle.vehicleType;
        _licensePlateController.text = vehicle.licensePlate;
      });
      await vehicleBox.deleteAt(index); // Temporarily remove to update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF63D1F6),
        title: const Text('Vehicle Registration',
            style: TextStyle(color: Color(0xFF585D61))),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF585D61)), // Profile icon
            onPressed: () {
              // Navigate to Profile Page or show user info
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Driver name field
              TextFormField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Driver Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle type field
              TextFormField(
                controller: _vehicleTypeController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vehicle Type is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License plate field
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'License Plate is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Register vehicle button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF63D1F6),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _registerVehicle,
                child: const Text(
                  'Register Vehicle',
                  style: TextStyle(
                      color: Colors.black, // Text color
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 24),

              // Display registered vehicles
              const Text(
                'Registered Vehicles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // List of registered vehicles using ValueListenableBuilder
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEAF4B), // Card container background color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
                    builder: (context, Box<Vehicle> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text('No vehicles registered'));
                      }

                      return ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          Vehicle? vehicle = box.getAt(index);
                          if (vehicle == null) return const SizedBox.shrink();

                          return Card(
                            color: const Color(0xFFDEAF4B),
                            child: ListTile(
                              title: Text(
                                  '${vehicle.vehicleType} - ${vehicle.licensePlate}',
                                  style: const TextStyle(color: Color(0xFF585D61))),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Driver: ${vehicle.driverName}',
                                      style: const TextStyle(
                                          color: Color(0xFF585D61))),
                                  Text('Registered at: ${vehicle.timestamp}',
                                      style: const TextStyle(
                                          color: Color(0xFF585D61))),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editVehicle(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteVehicle(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
