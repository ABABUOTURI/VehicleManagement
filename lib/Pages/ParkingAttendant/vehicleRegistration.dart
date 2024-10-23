import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

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

  int? selectedSlot;
  List<int> availableSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // Method to fetch available parking slots from Hive
  Future<void> _fetchAvailableSlots() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      availableSlots = parkingSlotBox.values
          .where((slot) => slot.isOccupied == false)
          .map((slot) => slot.slotId)
          .cast<int>()
          .toList();
    });
  }

  // Method to register a vehicle
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate() && selectedSlot != null) {
      // Create new Vehicle object
      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        phone: _driverPhoneController.text,
        vehicleType: _vehicleTypeController.text,
        slotId: selectedSlot!,
        timestamp: DateTime.now(),
        licensePlate: '', vehicleColor: '',
      );

      // Save vehicle to Hive
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      await vehicleBox.add(newVehicle);

      // Mark the parking slot as occupied
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      ParkingSlot? selectedParkingSlot = parkingSlotBox.values.firstWhere(
          (slot) => slot.slotId == selectedSlot,
          orElse: () => null!);
      selectedParkingSlot.isOccupied = true;
      parkingSlotBox.put(selectedSlot, selectedParkingSlot);
    
      // Clear form
      _clearForm();

      // Show confirmation and option to print parking ticket
      _showConfirmationDialog();
    }
  }

  // Method to clear form fields
  void _clearForm() {
    _driverNameController.clear();
    _driverPhoneController.clear();
    _vehicleTypeController.clear();
    setState(() {
      selectedSlot = null;
    });
  }

  // Confirmation Dialog with print ticket option
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vehicle Registered Successfully"),
        content: const Text("Do you want to print the parking ticket?"),
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
                      vertical: 15.0, horizontal: 10.0), // Padding inside input
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
                      vertical: 15.0, horizontal: 10.0), // Padding inside input
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
                      vertical: 15.0, horizontal: 10.0), // Padding inside input
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Parking Slot Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Parking Slot',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0), // Padding inside input
                ),
                value: selectedSlot,
                items: availableSlots
                    .map((slot) => DropdownMenuItem(
                        value: slot, child: Text('Slot $slot')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSlot = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a parking slot';
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
                child: Text('Register Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
