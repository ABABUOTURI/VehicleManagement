import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class DRVehicleRegistrationPage extends StatefulWidget {
  const DRVehicleRegistrationPage({super.key});

  @override
  _DRVehicleRegistrationPageState createState() =>
      _DRVehicleRegistrationPageState();
}

class _DRVehicleRegistrationPageState extends State<DRVehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();

  int? selectedSlot;
  List<int> availableSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // Fetch available parking slots from Hive
  Future<void> _fetchAvailableSlots() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      // Fetch slots that are not occupied
      availableSlots = parkingSlotBox.values
          .where((slot) => !slot.isOccupied)
          .map((slot) => slot.slotId)
          .cast<int>()
          .toList();
    });
  }

  // Register the vehicle in Hive and assign a parking slot
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate() && selectedSlot != null) {
      // Create a new Vehicle object
      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        vehicleType: _vehicleTypeController.text,
        licensePlate: _licensePlateController.text,
        vehicleColor: _vehicleColorController.text,
        slotId: selectedSlot!,
        timestamp: DateTime.now(), 
        phone: '', 
      );

      // Save vehicle to Hive
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      await vehicleBox.add(newVehicle);

      // Mark the parking slot as occupied
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      ParkingSlot? selectedParkingSlot = parkingSlotBox.values.firstWhere(
          (slot) => slot.slotId == selectedSlot);
      selectedParkingSlot?.isOccupied = true;
      parkingSlotBox.put(selectedSlot, selectedParkingSlot);

      // Clear form
      _clearForm();

      // Show confirmation
      _showConfirmationDialog();
    }
  }

  // Clear input fields
  void _clearForm() {
    _driverNameController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
    _vehicleColorController.clear();
    setState(() {
      selectedSlot = null;
    });
  }

  // Confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vehicle Registered Successfully"),
        content: Text("The vehicle has been assigned to slot $selectedSlot."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _vehicleColorController.dispose();
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
              // Driver Name Input
              TextFormField(
                controller: _driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Type Input
              TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Plate Input
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Color Input
              TextFormField(
                controller: _vehicleColorController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Parking Slot Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Select Parking Slot',
                  border: OutlineInputBorder(),
                ),
                value: selectedSlot,
                items: availableSlots
                    .map((slot) => DropdownMenuItem(
                          value: slot,
                          child: Text('Slot B$slot'),
                        ))
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
                  backgroundColor: const Color(0xFF63D1F6),
                  padding: const EdgeInsets.all(16.0),
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
