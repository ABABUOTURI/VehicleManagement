import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'dart:math'; // For generating unique ticket ID

class ParkingVehicleRegistrationPage extends StatefulWidget {
  const ParkingVehicleRegistrationPage({super.key});

  @override
  _ParkingVehicleRegistrationPageState createState() =>
      _ParkingVehicleRegistrationPageState();
}

class _ParkingVehicleRegistrationPageState
    extends State<ParkingVehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // Method to fetch available parking slots from Hive
  Future<void> _fetchAvailableSlots() async {
    // Implementation to fetch parking slots if needed for other operations
  }

  // Method to register a vehicle
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique ticket ID
      String ticketId = _generateUniqueTicketId();

      // Assume a slot ID is assigned automatically (for example, based on business logic)
      int assignedSlotId = 1; // Replace with actual logic for selecting a slot

      // Create new Vehicle object
      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        phone: _driverPhoneController.text,
        vehicleType: _vehicleTypeController.text,
        slotId: assignedSlotId,
        timestamp: DateTime.now(),
        licensePlate: _licensePlateController.text,
        vehicleColor: '',
        ticketId: ticketId, // Store the unique ticket ID in the vehicle object
      );

      // Save vehicle to Hive
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      await vehicleBox.add(newVehicle);

      // Mark the parking slot as occupied
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      ParkingSlot? selectedParkingSlot = parkingSlotBox.values.firstWhere(
          (slot) => slot.slotId == assignedSlotId,
          orElse: () => null!);
      selectedParkingSlot.isOccupied = true;
      parkingSlotBox.put(assignedSlotId, selectedParkingSlot);

      // Clear form
      _clearForm();

      // Show confirmation with the unique ticket ID
      _showConfirmationDialog(ticketId);

      // Update the parking slot UI color (automatic through ValueListenableBuilder)
    }
  }

  // Generate a unique ticket ID
  String _generateUniqueTicketId() {
    var random = Random();
    return 'TKT-${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  // Method to clear form fields
  void _clearForm() {
    _driverNameController.clear();
    _driverPhoneController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
    setState(() {
      // Reset state if needed
    });
  }

  // Confirmation Dialog with print ticket option
  void _showConfirmationDialog(String ticketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vehicle Registered Successfully"),
        content: Text("Your ticket ID is $ticketId.\nDo you want to print the parking ticket?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _printTicket();
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

  // Dummy method for printing ticket
  void _printTicket() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parking ticket printed successfully")),
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Registration'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Driver Name
              TextFormField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Driver Phone
              TextFormField(
                controller: _driverPhoneController,
                decoration: InputDecoration(
                  labelText: 'Driver Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver\'s phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Type
              TextFormField(
                controller: _vehicleTypeController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Register Vehicle Button
              ElevatedButton(
                onPressed: _registerVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: const Color(0xFF63D1F6),
                  textStyle: const TextStyle(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Register Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
